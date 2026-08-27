#!/usr/bin/env python3
"""
build-ai-docs.py — AI Web Chat Reading Path builder for the AX7035B PDF library.

Generates `viewer/ai/` (NOT committed; produced in CI and published via the
existing GitHub Pages artifact):

    viewer/ai/
      index.html          static doc list (core content needs no JavaScript)
      index.json          machine routing index for web chat AIs
      AI_USAGE.txt        plain-text instructions for AIs
      docs/<doc_id>/
        manifest.json     per-document extraction manifest (source of truth)
        full.txt          whole-document text with per-page TEXT_SOURCE markers
        full.html         lightweight HTML version of full.txt
        pages/0001.txt    one file per physical PDF page (1-based)
        blocks/0001.json  per-page text blocks with bboxes (embedded or OCR)

Extraction strategy: Embedded Text First + OCR Fallback.
  - embedded text sufficient  -> TEXT_SOURCE=embedded  (never OCR)
  - little/no text + large raster coverage -> scan_candidate -> OCR
  - some text + large raster coverage      -> mixed_candidate -> OCR, marked mixed
  - blank / decorative pages  -> TEXT_SOURCE=none      (never OCR)
OCR = local Tesseract only (chi_sim+eng, ~300 DPI, temp PNG deleted after use).
No cloud OCR, no API keys. Git-LFS pointer files are detected and marked
`lfs_not_materialized` — never parsed as PDF text.

Determinism / incremental:
  - doc_id = sha256(normalized repo-relative PDF path)[:16]  (stable per path)
  - a doc is reused if its manifest matches source SHA256 + extractor version
    + OCR config version; cache is an optimization, never a correctness need.
  - chunking: --chunk I/N assigns docs by hash so the split is stable when
    PDFs are added/removed.

Usage:
  python3 scripts/build-ai-docs.py build [--chunk 0/8] [--only SUBSTR] [--force]
                                        [--max-ocr-pages N] [--workers W] [--dry-run]
  python3 scripts/build-ai-docs.py combine [--out DIR]
  python3 scripts/build-ai-docs.py cachekey
"""

import argparse
import hashlib
import html as html_mod
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
from urllib.parse import quote

# PyMuPDF is only needed by the `build` subcommand; `combine` / `cachekey`
# must run on a stdlib-only environment (e.g. the finalize CI job).
pymupdf = None
try:
    import pymupdf  # PyMuPDF >= 1.24
except ImportError:  # pragma: no cover
    try:
        import fitz as pymupdf  # legacy name
    except ImportError:
        pymupdf = None


def _require_pymupdf():
    if pymupdf is None:
        raise SystemExit("[build] PyMuPDF is required for this subcommand: pip install pymupdf")
    return pymupdf

# --------------------------------------------------------------------------
# Configuration (simple, explainable, overridable via environment)
# --------------------------------------------------------------------------
EXTRACTOR_VERSION = os.environ.get("AI_EXTRACTOR_VERSION", "1")
OCR_CONFIG_VERSION = "tesseract-chi_sim+eng-300dpi-psm3-v1"

EMBEDDED_RICH_CHARS = int(os.environ.get("AI_EMBEDDED_RICH_CHARS", "400"))
EMBEDDED_MIN_CHARS = int(os.environ.get("AI_EMBEDDED_MIN_CHARS", "50"))
IMG_COV_THRESHOLD = float(os.environ.get("AI_IMG_COV_THRESHOLD", "0.35"))

OCR_DPI = int(os.environ.get("AI_OCR_DPI", "300"))
OCR_LANG = os.environ.get("AI_OCR_LANG", "chi_sim+eng")
OCR_PSM = os.environ.get("AI_OCR_PSM", "3")
OCR_PAGE_TIMEOUT = int(os.environ.get("AI_OCR_PAGE_TIMEOUT", "180"))
OCR_BUDGET_MIN = float(os.environ.get("OCR_BUDGET_MIN", "150"))
OCR_MIN_LINE_CONF = float(os.environ.get("AI_OCR_MIN_CONF", "30"))

SPARSE_PAGE_CHARS = int(os.environ.get("AI_SPARSE_PAGE_CHARS", "20"))
SPARSE_DOC_CHARS = int(os.environ.get("AI_SPARSE_DOC_CHARS", "200"))

REPO_OWNER = os.environ.get("REPO_OWNER", "yeblue1029")
REPO_NAME = os.environ.get("REPO_NAME", "AX7035B-learning-materials-backup")
REPO_BRANCH = os.environ.get("REPO_BRANCH", "main")
PAGES_BASE_URL = os.environ.get("PAGES_BASE_URL",
                                f"https://{REPO_OWNER}.github.io/{REPO_NAME}").rstrip("/")
COMMIT_SHA = os.environ.get("COMMIT_SHA", "unknown")
WORKERS_DEFAULT = min(4, os.cpu_count() or 2)

REPOSITORY = f"{REPO_OWNER}/{REPO_NAME}"
GENERATOR = "scripts/build-ai-docs.py"

# Mirror of scan-pdfs.mjs exclusion rules (keep both scanners in sync).
EXCLUDE_DIRS = {".git", "node_modules", "_github_worktree", "_github_extract_staging",
                "_github_upload_logs", ".github_upload_logs", "_github_scan", ".Xil",
                ".vscode", ".idea", ".vs", ".trae", "AI_REPO_INDEX", "viewer"}
BUILD_DIR_SUFFIXES = (".runs", ".cache", ".hw", ".sim", ".gen", "ip_user_files")

POSSIBLE_STATUSES = ("ok", "partial", "text_sparse", "invalid_pdf",
                     "lfs_not_materialized", "ocr_failed", "error")
LFS_POINTER_PREFIX = b"version https://git-lfs.github.com/spec/v1"

# --------------------------------------------------------------------------
# Discovery helpers (shared with verify-ai-docs.py conventions)
# --------------------------------------------------------------------------

def find_pdf_files(root):
    """All repo PDFs (posix rel paths), excluding non-content dirs. Sorted."""
    out = []
    for dirpath, dirnames, filenames in os.walk(root):
        rel_parts = os.path.relpath(dirpath, root).split(os.sep)
        if rel_parts == ["."]:
            rel_parts = []
        if any(p in EXCLUDE_DIRS for p in rel_parts):
            dirnames[:] = []
            continue
        if any(p.endswith(s) for p in rel_parts for s in BUILD_DIR_SUFFIXES):
            dirnames[:] = []
            continue
        dirnames.sort()
        for f in sorted(filenames):
            if f.lower().endswith(".pdf"):
                rel = "/".join(rel_parts + [f]) if rel_parts else f
                out.append(rel)
    return out


def load_lfs_matchers(root):
    """Port of scan-pdfs.mjs .gitattributes glob -> regex LFS matching."""
    ga = os.path.join(root, ".gitattributes")
    matchers = []
    if not os.path.isfile(ga):
        return matchers
    with open(ga, "r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = re.match(r"^\s*(\S+)\s+.*filter=lfs\b", line)
            if not m:
                continue
            pat = m.group(1).lstrip("/")
            re_str = ""
            i = 0
            while i < len(pat):
                c = pat[i]
                if c == "*" and i + 1 < len(pat) and pat[i + 1] == "*":
                    i += 2
                    if i < len(pat) and pat[i] == "/":
                        i += 1
                    re_str += ".*"
                elif c == "*":
                    re_str += "[^/]*"
                    i += 1
                elif c == "?":
                    re_str += "[^/]"
                    i += 1
                elif c in ".+^$(){}|[]\\":
                    re_str += "\\" + c
                    i += 1
                else:
                    re_str += c
                    i += 1
            try:
                matchers.append(re.compile("^" + re_str + "$"))
            except re.error:
                pass
    return matchers


def file_sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def doc_id_for(rel_path):
    return hashlib.sha256(rel_path.encode("utf-8")).hexdigest()[:16]


def encode_repo_path(rel_path):
    return "/".join(quote(seg, safe="") for seg in rel_path.split("/"))


def urls_for(rel_path, doc_id):
    enc = encode_repo_path(rel_path)
    raw = f"https://raw.githubusercontent.com/{REPO_OWNER}/{REPO_NAME}/{REPO_BRANCH}/{enc}"
    return {
        "ai_full_text_url": f"{PAGES_BASE_URL}/ai/docs/{doc_id}/full.txt",
        "ai_full_html_url": f"{PAGES_BASE_URL}/ai/docs/{doc_id}/full.html",
        "ai_pages_base_url": f"{PAGES_BASE_URL}/ai/docs/{doc_id}/pages",
        "ai_blocks_base_url": f"{PAGES_BASE_URL}/ai/docs/{doc_id}/blocks",
        "manifest_url": f"{PAGES_BASE_URL}/ai/docs/{doc_id}/manifest.json",
        "original_github_url": f"https://github.com/{REPO_OWNER}/{REPO_NAME}/blob/{REPO_BRANCH}/{enc}",
        "original_raw_url": raw,
        "viewer_url": f"{PAGES_BASE_URL}/web/viewer.html?file={quote(raw, safe='')}",
    }


def sniff_header(path, read=64):
    try:
        with open(path, "rb") as fh:
            return fh.read(read)
    except OSError:
        return b""


def is_lfs_pointer(path):
    return sniff_header(path).startswith(LFS_POINTER_PREFIX)


# --------------------------------------------------------------------------
# Page classification & OCR
# --------------------------------------------------------------------------

def classify_page(text_chars, img_cov):
    """embedded | scan_candidate | mixed_candidate | none (explainable thresholds)."""
    if text_chars >= EMBEDDED_RICH_CHARS and img_cov < IMG_COV_THRESHOLD:
        return "embedded"           # native text clearly sufficient -> never OCR
    if text_chars >= EMBEDDED_RICH_CHARS:
        return "embedded"           # rich text even over watermark/background image
    if img_cov >= IMG_COV_THRESHOLD:
        return "mixed_candidate" if text_chars >= EMBEDDED_MIN_CHARS else "scan_candidate"
    if text_chars >= EMBEDDED_MIN_CHARS:
        return "embedded"           # sparse-but-real text, no big raster -> native
    return "none"                   # blank / decorative page -> never OCR


def _is_cjk(ch):
    o = ord(ch)
    return (0x3000 <= o <= 0x303F) or (0x4E00 <= o <= 0x9FFF) or \
           (0xF900 <= o <= 0xFAFF) or (0xFF00 <= o <= 0xFFEF)


def join_words(words):
    """Join tesseract words; avoid injecting spaces inside CJK runs."""
    if not words:
        return ""
    out = words[0]
    for w in words[1:]:
        if not w:
            continue
        if out and _is_cjk(out[-1]) and _is_cjk(w[0]):
            out += w
        else:
            out += " " + w
    return out


def parse_tsv(tsv_text):
    """Group tesseract TSV words into lines -> [(bbox, text)] in reading order."""
    lines = {}
    order = []
    for row in tsv_text.splitlines()[1:]:
        cols = row.split("\t")
        if len(cols) < 12:
            continue
        try:
            level = int(cols[0]); block = int(cols[2]); par = int(cols[3])
            line = int(cols[4]); left = int(cols[6]); top = int(cols[7])
            width = int(cols[8]); height = int(cols[9]); conf = float(cols[10])
        except ValueError:
            continue
        text = cols[11]
        if level != 5 or conf < OCR_MIN_LINE_CONF or not text.strip():
            continue
        key = (block, par, line)
        if key not in lines:
            lines[key] = {"words": [], "bbox": [left, top, left + width, top + height]}
            order.append(key)
        L = lines[key]
        L["words"].append(text)
        b = L["bbox"]
        b[0] = min(b[0], left); b[1] = min(b[1], top)
        b[2] = max(b[2], left + width); b[3] = max(b[3], top + height)
    result = [(lines[k]["bbox"], join_words(lines[k]["words"])) for k in order]
    return result


def run_tesseract(png_path):
    """Returns (tsv_text) or raises. Local engine only."""
    env = dict(os.environ)
    env["OMP_THREAD_LIMIT"] = "1"   # parallelism comes from worker processes
    cmd = ["tesseract", png_path, "stdout", "-l", OCR_LANG, "--psm", OCR_PSM, "tsv"]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=OCR_PAGE_TIMEOUT, env=env)
    except subprocess.TimeoutExpired:
        raise RuntimeError("tesseract timeout")
    if proc.returncode != 0:
        raise RuntimeError(f"tesseract exit {proc.returncode}: {proc.stderr[:200]}")
    return proc.stdout


def render_page_png(page, dpi):
    import tempfile as _tf
    pix = page.get_pixmap(dpi=dpi, alpha=False)
    fd, png = _tf.mkstemp(suffix=".png", prefix="aiocr_")   # runner temp dir
    os.close(fd)
    pix.save(png)
    return png


def image_coverage(page):
    """Fraction of page area covered by raster images (clipped to page, capped 1.0)."""
    area = abs(page.rect.width * page.rect.height) or 1.0
    cov = 0.0
    try:
        infos = page.get_image_info()
    except Exception:
        infos = []
    for info in infos:
        b = info.get("bbox")
        if not b:
            continue
        w = max(0.0, min(b[2], page.rect.x1) - max(b[0], page.rect.x0))
        h = max(0.0, min(b[3], page.rect.y1) - max(b[1], page.rect.y0))
        cov += (w * h) / area
    return min(cov, 1.0)


# --------------------------------------------------------------------------
# Per-document worker
# --------------------------------------------------------------------------

WORKER_CFG = {}

def process_document(rel_path):
    cfg = WORKER_CFG
    root = cfg["root"]
    out_docs = cfg["out_docs"]
    abs_path = os.path.join(root, rel_path)
    did = doc_id_for(rel_path)
    doc_dir = os.path.join(out_docs, did)
    t_start = time.time()

    m = {
        "title": os.path.splitext(os.path.basename(rel_path))[0],
        "display_title": os.path.splitext(os.path.basename(rel_path))[0],
        "filename": os.path.basename(rel_path),
        "source_path": rel_path,
        "doc_id": did,
        "source_sha256": "",
        "file_size": 0,
        "pdf_page_count": 0,
        "repository": REPOSITORY,
        "branch": REPO_BRANCH,
        "commit_sha": COMMIT_SHA,
        "pymupdf_version": pymupdf.__doc__.split(":")[0].replace("PyMuPDF", "").strip() or pymupdf.version[0],
        "ocr_engine": "tesseract",
        "ocr_engine_version": cfg.get("tesseract_version", ""),
        "ocr_languages": OCR_LANG,
        "extraction_status": "error",
        "embedded_page_count": 0, "ocr_page_count": 0, "mixed_page_count": 0,
        "empty_page_count": 0, "error_pages": 0, "sparse_pages": 0,
        "scan_candidate_pages": 0, "mixed_candidate_pages": 0,
        "ocr_deferred_pages": 0, "ocr_failed_pages": 0,
        "text_char_count": 0,
        "extractor_version": EXTRACTOR_VERSION,
        "ocr_config_version": OCR_CONFIG_VERSION,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "build_seconds": 0.0, "ocr_seconds": 0.0,
    }

    try:
        m["file_size"] = os.path.getsize(abs_path)
        m["source_sha256"] = file_sha256(abs_path)
    except OSError as e:
        m["extraction_status"] = "error"
        m["notes"] = f"io_error:{e}"
        _write_manifest(doc_dir, m)
        return m

    header = sniff_header(abs_path)
    if header.startswith(LFS_POINTER_PREFIX):
        m["extraction_status"] = "lfs_not_materialized"
        m["notes"] = ("Git-LFS pointer checked out (object not materialized). "
                      "Not parsed as PDF. Fetch the LFS object to extract text.")
        _write_manifest(doc_dir, m)
        return m
    if not header.startswith(b"%PDF-"):
        m["extraction_status"] = "invalid_pdf"
        m["notes"] = "file does not start with %PDF- header"
        _write_manifest(doc_dir, m)
        return m

    deadline = cfg["deadline"]
    budget_available = lambda: time.time() < deadline
    ocr_budget_note = "ocr_budget_exceeded"
    max_ocr = cfg["max_ocr_pages"]
    ocr_done = 0

    pages_txt, blocks_json = [], []
    full_txt_parts, full_html_parts = [], []
    total_chars = 0

    try:
        doc = pymupdf.open(abs_path)
    except Exception as e:
        m["extraction_status"] = "invalid_pdf"
        m["notes"] = f"pymupdf_open_failed:{type(e).__name__}"
        _write_manifest(doc_dir, m)
        return m

    m["pdf_page_count"] = doc.page_count

    # document title from metadata (validated)
    meta_title = (doc.metadata or {}).get("title", "") or ""
    meta_title = meta_title.strip()
    if (2 <= len(meta_title) <= 200 and ".pdf" not in meta_title.lower()
            and meta_title.lower() not in ("untitled", "microsoft word - 文档1", "print")
            and sum(ch.isprintable() for ch in meta_title) / max(len(meta_title), 1) > 0.9):
        m["title"] = meta_title

    try:
        for pno in range(doc.page_count):
            page = doc[pno]
            page_src, notes = "none", []
            embedded_text, emb_blocks = "", []
            chars, cov = 0, 0.0
            try:
                raw = page.get_text("text")
                embedded_text = raw
                chars = len("".join(raw.split()))
                cov = image_coverage(page)
                # embedded blocks (PyMuPDF dict) for block-level bbox
                d = page.get_text("dict")
                for blk in d.get("blocks", []):
                    if blk.get("type") == 0:
                        txt = "\n".join(
                            "".join(span.get("text", "") for span in ln.get("spans", []))
                            for ln in blk.get("lines", []))
                        emb_blocks.append({"bbox": [round(v, 1) for v in blk["bbox"]],
                                           "type": "text", "source": "embedded", "text": txt})
                    else:
                        emb_blocks.append({"bbox": [round(v, 1) for v in blk["bbox"]],
                                           "type": "image", "source": "embedded"})
            except Exception:
                page_src, notes = "error", ["embedded_extraction_failed"]

            cls = classify_page(chars if page_src != "error" else 0, cov if page_src != "error" else 0.0)
            if cls == "scan_candidate":
                m["scan_candidate_pages"] += 1
            elif cls == "mixed_candidate":
                m["mixed_candidate_pages"] += 1

            ocr_lines, ocr_blocks, ocr_text = [], [], ""
            ocr_meta = []
            if page_src == "error":
                m["error_pages"] += 1
                final_text = ""
            elif cls in ("scan_candidate", "mixed_candidate"):
                reason = None
                if not cfg["tesseract_available"]:
                    reason = "ocr_unavailable"
                elif max_ocr is not None and ocr_done >= max_ocr:
                    reason = "ocr_limited_for_test"
                elif not budget_available():
                    reason = ocr_budget_note
                if reason:
                    m["ocr_deferred_pages"] += 1
                    notes.append(reason)
                    if cls == "mixed_candidate":
                        # embedded text we already have; OCR overlay deferred
                        page_src = "embedded"
                        final_text = embedded_text
                    else:
                        page_src = "none"
                        final_text = ""
                else:
                    t0 = time.time()
                    png = None
                    try:
                        png = render_page_png(page, OCR_DPI)
                        tsv = run_tesseract(png)
                        ocr_lines = parse_tsv(tsv)
                        ocr_text = "\n".join(t for _, t in ocr_lines)
                        ocr_blocks = [{"bbox": [round(v, 1) for v in bb], "type": "ocr_line",
                                       "source": "ocr", "text": t} for bb, t in ocr_lines]
                        ocr_done += 1
                    except Exception as e:
                        m["ocr_failed_pages"] += 1
                        notes.append(f"ocr_failed:{type(e).__name__}")
                    finally:
                        if png and os.path.exists(png):
                            os.unlink(png)          # temp PNG deleted after use
                    m["ocr_seconds"] += time.time() - t0

                    if cls == "mixed_candidate":
                        page_src = "mixed"
                        final_text = embedded_text.rstrip() + "\n[OCR layer]\n" + ocr_text if ocr_text else embedded_text
                        ocr_meta = ["OCR_ENGINE: tesseract", f"OCR_LANGUAGE: {OCR_LANG}",
                                    f"OCR_DPI: {OCR_DPI}"]
                    else:
                        if ocr_text.strip():
                            page_src = "ocr"
                            ocr_meta = ["OCR_ENGINE: tesseract", f"OCR_LANGUAGE: {OCR_LANG}",
                                        f"OCR_DPI: {OCR_DPI}"]
                        else:
                            page_src = "none"
                            if not notes:
                                notes.append("ocr_empty_result")
                        final_text = ocr_text
            elif cls == "embedded":
                page_src = "embedded"
                final_text = embedded_text
            else:
                page_src = "none"
                final_text = ""
                notes.append("blank_or_decorative_page")

            # counters
            if page_src == "embedded":
                m["embedded_page_count"] += 1
            elif page_src == "ocr":
                m["ocr_page_count"] += 1
            elif page_src == "mixed":
                m["mixed_page_count"] += 1
            elif page_src == "none":
                m["empty_page_count"] += 1

            fchars = len("".join(final_text.split()))
            if page_src != "error":
                total_chars += fchars
                if fchars < SPARSE_PAGE_CHARS:
                    m["sparse_pages"] += 1

            # ---- pages/NNNN.txt ----
            head = [f"DOCUMENT_TITLE: {m['title']}",
                    f"SOURCE_PATH: {rel_path}",
                    f"PDF_PAGE: {pno + 1}",
                    f"PDF_PAGE_COUNT: {m['pdf_page_count']}",
                    f"SOURCE_SHA256: {m['source_sha256']}",
                    f"TEXT_SOURCE: {page_src}"]
            head += ocr_meta
            if notes:
                head.append("NOTE: " + ", ".join(notes))
            page_file = "\n".join(head) + "\n\n" + (final_text.strip() or "(no text on this page)")
            pages_txt.append((f"{pno + 1:04d}.txt", page_file))

            # ---- blocks/NNNN.json ----
            blk_doc = {
                "pdf_page": pno + 1,
                "text_source": page_src,
                "block_source": {"embedded": "pymupdf", "ocr": "tesseract_tsv",
                                 "mixed": "pymupdf+tesseract_tsv"}.get(page_src, "none"),
                "page_size": [round(page.rect.width, 1), round(page.rect.height, 1)],
                "contains_images": cov > 0 or any(b["type"] == "image" for b in emb_blocks),
                "image_coverage": round(cov, 3),
                "blocks": (emb_blocks + ocr_blocks) if page_src != "error" else [],
                "notes": notes,
            }
            blocks_json.append((f"{pno + 1:04d}.json", blk_doc))

            # ---- full.txt accumulation ----
            seg = [f"========== PDF_PAGE {pno + 1:04d} ==========",
                   f"TEXT_SOURCE: {page_src}"] + ocr_meta
            if notes:
                seg.append("NOTE: " + ", ".join(notes))
            full_txt_parts.append("\n".join(seg) + "\n\n" + (final_text.strip() or "(no text on this page)"))

            # ---- full.html accumulation ----
            badge = {"embedded": "embedded", "ocr": "OCR", "mixed": "mixed",
                     "none": "no text", "error": "error"}[page_src]
            full_html_parts.append(
                f'<section id="page-{pno + 1:04d}"><h3>PDF_PAGE {pno + 1:04d} '
                f'<span class="badge {page_src}">{badge}</span></h3>'
                f'<pre>{html_mod.escape(final_text.strip() or "(no text on this page)")}</pre></section>')
        doc.close()
    except Exception as e:
        m["extraction_status"] = "error"
        m["notes"] = f"page_loop_failed:{type(e).__name__}:{e}"
        m["build_seconds"] = round(time.time() - t_start, 1)
        _write_manifest(doc_dir, m)
        return m

    m["text_char_count"] = total_chars

    if m["error_pages"] or m["ocr_deferred_pages"] or m["ocr_failed_pages"]:
        m["extraction_status"] = "partial"
    elif total_chars < SPARSE_DOC_CHARS and m["pdf_page_count"] > 0:
        m["extraction_status"] = "text_sparse"
    else:
        m["extraction_status"] = "ok"
    if m["ocr_failed_pages"] and (m["embedded_page_count"] + m["mixed_page_count"]) == 0 \
            and m["ocr_page_count"] == 0 and m["pdf_page_count"] > 0:
        m["extraction_status"] = "ocr_failed"

    # ---- write outputs (manifest LAST: its presence marks the doc complete) ----
    if not cfg["dry_run"]:
        pages_dir = os.path.join(doc_dir, "pages")
        blocks_dir = os.path.join(doc_dir, "blocks")
        os.makedirs(pages_dir, exist_ok=True)
        os.makedirs(blocks_dir, exist_ok=True)
        for name, content in pages_txt:
            with open(os.path.join(pages_dir, name), "w", encoding="utf-8") as fh:
                fh.write(content)
        for name, obj in blocks_json:
            with open(os.path.join(blocks_dir, name), "w", encoding="utf-8") as fh:
                json.dump(obj, fh, ensure_ascii=False)
        full_header = (f"DOCUMENT_TITLE: {m['title']}\n"
                       f"SOURCE_PATH: {rel_path}\n"
                       f"PDF_PAGE_COUNT: {m['pdf_page_count']}\n"
                       f"SOURCE_SHA256: {m['source_sha256']}\n"
                       f"EXTRACTION_STATUS: {m['extraction_status']}\n\n")
        with open(os.path.join(doc_dir, "full.txt"), "w", encoding="utf-8") as fh:
            fh.write(full_header + "\n\n".join(full_txt_parts) + "\n")
        with open(os.path.join(doc_dir, "full.html"), "w", encoding="utf-8") as fh:
            fh.write(_full_html_doc(m, full_html_parts))

    m["build_seconds"] = round(time.time() - t_start, 1)
    _write_manifest(doc_dir, m, dry=cfg["dry_run"])
    return m


def _write_manifest(doc_dir, m, dry=False):
    if dry:
        return
    os.makedirs(doc_dir, exist_ok=True)
    with open(os.path.join(doc_dir, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(m, fh, ensure_ascii=False, indent=1)


def _full_html_doc(m, sections):
    return ("<!doctype html>\n<html lang=\"zh-CN\">\n<head><meta charset=\"utf-8\">\n"
            f"<title>{html_mod.escape(m['title'])} · AI full text</title>\n"
            "<style>body{font-family:'Noto Sans CJK SC','WenQuanYi Micro Hei',sans-serif;"
            "max-width:900px;margin:0 auto;padding:24px;line-height:1.6;color:#1c2330;"
            "background:#fff}h1{font-size:22px}pre{white-space:pre-wrap;word-break:break-word;"
            "background:#f6f8fa;padding:10px;border-radius:8px;font-size:14px}"
            ".badge{font-size:11px;padding:2px 8px;border-radius:99px;margin-left:8px;"
            "background:#58a6ff;color:#fff}.badge.ocr,.badge.mixed{background:#d29922}"
            ".badge.none{background:#8b98a5}.badge.error{background:#f85149}"
            "section{border-top:1px solid #e1e4e8;padding-top:8px;margin-top:16px}"
            "h3{font-size:15px}meta,small{color:#57606a}</style></head>\n<body>\n"
            f"<h1>{html_mod.escape(m['title'])}</h1>\n"
            f"<p><small>SOURCE_PATH: {html_mod.escape(m['source_path'])} | "
            f"PDF_PAGE_COUNT: {m['pdf_page_count']} | SOURCE_SHA256: {m['source_sha256']} | "
            f"EXTRACTION_STATUS: {m['extraction_status']} | "
            f"embedded/ocr/mixed/none/error = {m['embedded_page_count']}/{m['ocr_page_count']}/"
            f"{m['mixed_page_count']}/{m['empty_page_count']}/{m['error_pages']}</small></p>\n"
            "<p><small>OCR text is for search/location/general reading only — verify "
            "pins, registers, numbers, formulas against the original PDF.</small></p>\n"
            + "\n".join(sections) + "\n</body>\n</html>\n")


# --------------------------------------------------------------------------
# build subcommand
# --------------------------------------------------------------------------

def reuse_manifest(doc_dir, sha):
    """Return saved manifest if it matches source sha + versions (cache reuse)."""
    mp = os.path.join(doc_dir, "manifest.json")
    if not os.path.isfile(mp):
        return None
    try:
        with open(mp, "r", encoding="utf-8") as fh:
            m = json.load(fh)
    except (OSError, json.JSONDecodeError):
        return None
    if (m.get("source_sha256") == sha
            and m.get("extractor_version") == EXTRACTOR_VERSION
            and m.get("ocr_config_version") == OCR_CONFIG_VERSION):
        return m
    return None


def cmd_build(args):
    _require_pymupdf()
    root = os.path.abspath(args.root)
    out_dir = os.path.abspath(args.out)
    out_docs = os.path.join(out_dir, "docs")
    os.makedirs(out_docs, exist_ok=True)

    all_docs = find_pdf_files(root)
    lfs_matchers = load_lfs_matchers(root)
    lfs_flag = {p: any(rx.match(p) for rx in lfs_matchers) for p in all_docs}

    selected = all_docs
    if args.only:
        selected = [p for p in all_docs
                    if any(s.lower() in p.lower() for s in args.only)]
    if args.chunk:
        num, den = args.chunk.split("/")
        num, den = int(num), int(den)
        if den > 1:
            selected = [p for p in selected
                        if int(doc_id_for(p)[:8], 16) % den == num]

    print(f"[build] repo root       : {root}")
    print(f"[build] all PDFs        : {len(all_docs)} "
          f"(git-lfs tracked by attributes: {sum(lfs_flag.values())})")
    print(f"[build] selected docs   : {len(selected)} "
          f"(chunk={args.chunk}, only={args.only or '-'})")
    print(f"[build] output          : {out_dir}")
    print(f"[build] extractor v{EXTRACTOR_VERSION} / ocr cfg {OCR_CONFIG_VERSION} / "
          f"ocr budget {OCR_BUDGET_MIN} min / workers {args.workers}")

    tesseract_version = ""
    tsv = shutil.which("tesseract")
    if tsv:
        try:
            tesseract_version = subprocess.run(["tesseract", "--version"],
                                               capture_output=True, text=True, timeout=30
                                               ).stdout.splitlines()[0].strip()
        except Exception:
            tesseract_version = "unknown"
    print(f"[build] tesseract       : {tesseract_version or 'NOT FOUND (scan pages -> none/deferred)'}")

    cfg = {
        "root": root, "out_docs": out_docs, "dry_run": args.dry_run,
        "tesseract_available": bool(tsv), "tesseract_version": tesseract_version,
        "max_ocr_pages": args.max_ocr_pages,
        "deadline": time.time() + OCR_BUDGET_MIN * 60,
    }

    results, reused, processed = [], 0, 0
    t0 = time.time()
    todo = []
    for p in selected:
        did = doc_id_for(p)
        doc_dir = os.path.join(out_docs, did)
        if not args.force:
            sha = file_sha256(os.path.join(root, p))
            old = reuse_manifest(doc_dir, sha)
            if old is not None:
                results.append(old)
                reused += 1
                continue
        todo.append(p)

    if args.dry_run:
        print(f"[build] DRY RUN — no files written")
    print(f"[build] reuse from cache: {reused} | to process: {len(todo)}")

    if todo:
        global WORKER_CFG
        WORKER_CFG = cfg
        workers = max(1, min(args.workers, len(todo)))
        if workers == 1 or args.dry_run:
            for p in todo:
                results.append(process_document(p))
                processed += 1
                print(f"[build] {processed}/{len(todo)} done: {p}", flush=True)
        else:
            ctx = get_context()
            with ProcessPoolExecutor(max_workers=workers, mp_context=ctx) as ex:
                futs = {ex.submit(_run_worker, p, cfg): p for p in todo}
                for i, fut in enumerate(as_completed(futs), 1):
                    p = futs[fut]
                    try:
                        m = fut.result()
                    except Exception as e:
                        m = {"source_path": p, "doc_id": doc_id_for(p),
                             "extraction_status": "error",
                             "notes": f"worker_crash:{type(e).__name__}:{e}",
                             "pdf_page_count": 0, "embedded_page_count": 0,
                             "ocr_page_count": 0, "mixed_page_count": 0,
                             "empty_page_count": 0, "error_pages": 0,
                             "sparse_pages": 0, "scan_candidate_pages": 0,
                             "mixed_candidate_pages": 0, "ocr_deferred_pages": 0,
                             "ocr_failed_pages": 0, "text_char_count": 0,
                             "build_seconds": 0.0, "ocr_seconds": 0.0}
                        _write_manifest(os.path.join(out_docs, m["doc_id"]), m)
                    results.append(m)
                    print(f"[build] {i}/{len(todo)} [{m['extraction_status']:>20}] "
                          f"ocr={m['ocr_seconds']:6.1f}s total={m['build_seconds']:6.1f}s : {p}",
                          flush=True)

    elapsed = time.time() - t0
    agg = _aggregate(results)
    print(f"[build] chunk done in {elapsed:.0f}s — statuses: {agg['statuses']}")
    print(f"[build] pages embedded/ocr/mixed/none/error: "
          f"{agg['embedded']}/{agg['ocr']}/{agg['mixed']}/{agg['none']}/{agg['error_pages']}")
    return 0


def get_context():
    import multiprocessing as mp
    try:
        return mp.get_context("fork")
    except ValueError:
        return mp.get_context("spawn")


def _run_worker(rel, cfg):
    global WORKER_CFG
    WORKER_CFG = cfg
    return process_document(rel)


def _aggregate(results):
    st = {}
    for r in results:
        st[r["extraction_status"]] = st.get(r["extraction_status"], 0) + 1
    return {
        "statuses": st,
        "docs": len(results),
        "pages": sum(r.get("pdf_page_count", 0) for r in results),
        "embedded": sum(r.get("embedded_page_count", 0) for r in results),
        "ocr": sum(r.get("ocr_page_count", 0) for r in results),
        "mixed": sum(r.get("mixed_page_count", 0) for r in results),
        "none": sum(r.get("empty_page_count", 0) for r in results),
        "error_pages": sum(r.get("error_pages", 0) for r in results),
        "ocr_seconds": round(sum(r.get("ocr_seconds", 0.0) for r in results), 1),
    }


# --------------------------------------------------------------------------
# combine subcommand
# --------------------------------------------------------------------------

INDEX_HTML_HEAD = """<!doctype html>
<html lang="zh-CN">
<head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>AI Reading Path · AX7035B Learning Materials</title>
<style>
:root{--bg:#0f1419;--panel:#161b22;--panel2:#1c2330;--border:#2a3340;--text:#e6edf3;
--muted:#8b98a5;--accent:#58a6ff;--green:#3fb950;--warn:#d29922;--danger:#f85149}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);
font-family:"Noto Sans CJK SC","WenQuanYi Micro Hei",-apple-system,"Segoe UI",Roboto,
"PingFang SC","Microsoft YaHei",sans-serif;line-height:1.55}
.wrap{max-width:1240px;margin:0 auto;padding:28px 20px 80px}
h1{font-size:26px;margin:6px 0}.lead{color:var(--muted);max-width:900px;font-size:14px}
.pill{display:inline-block;background:var(--panel2);border:1px solid var(--border);
border-radius:99px;padding:6px 14px;margin:4px 6px 4px 0;font-size:13px}
.pill a{color:var(--accent);text-decoration:none}
.stats{display:flex;flex-wrap:wrap;gap:12px;margin:18px 0}
.stat{background:var(--panel);border:1px solid var(--border);border-radius:12px;
padding:12px 16px;min-width:110px}.stat .n{font-size:20px;font-weight:800}
.stat .l{font-size:12px;color:var(--muted)}
#q{width:100%;max-width:520px;background:var(--panel2);border:1px solid var(--border);
border-radius:10px;color:var(--text);padding:11px 14px;font-size:14px;outline:none;margin:10px 0}
table{width:100%;border-collapse:collapse;font-size:13.5px}
th{position:sticky;top:0;background:var(--panel);text-align:left;color:var(--muted);
font-size:12px;padding:9px 10px;border-bottom:1px solid var(--border)}
td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,.05);vertical-align:top}
tr:hover td{background:rgba(88,166,255,.05)}
.t{font-weight:600;word-break:break-all}.p{color:var(--muted);font-size:12px;word-break:break-all}
a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}
.badge{font-size:10.5px;font-weight:700;padding:2px 8px;border-radius:99px;white-space:nowrap}
.badge.ok{background:rgba(63,185,80,.16);color:var(--green);border:1px solid rgba(63,185,80,.4)}
.badge.partial{background:rgba(210,153,34,.16);color:var(--warn);border:1px solid rgba(210,153,34,.4)}
.badge.text_sparse{background:rgba(139,152,165,.16);color:var(--muted);border:1px solid var(--border)}
.badge.invalid_pdf,.badge.error,.badge.ocr_failed{background:rgba(248,81,73,.15);color:var(--danger);border:1px solid rgba(248,81,73,.4)}
.badge.lfs_not_materialized{background:rgba(210,153,34,.16);color:var(--warn);border:1px solid rgba(210,153,34,.4)}
.foot{margin-top:24px;color:var(--muted);font-size:12.5px}
code{background:var(--panel2);padding:1px 6px;border-radius:5px}
</style></head>
<body><div class="wrap">
<h1>🤖 AI Reading Path — AX7035B PDF 全文文本</h1>
<p class="lead">本页为静态 HTML，核心文档列表直接在源码中，无需 JavaScript 即可读取。
机器入口：<code>index.json</code> · 使用说明：<code>AI_USAGE.txt</code> · 人读请用
<a href="../">PDF.js 文档中心</a>。OCR 页文本仅供搜索/定位，关键事实请回原 PDF 复核。</p>
"""


def cmd_combine(args):
    root = os.path.abspath(args.root)
    out_dir = os.path.abspath(args.out)
    docs_dir = os.path.join(out_dir, "docs")

    current = find_pdf_files(root)
    current_ids = {doc_id_for(p): p for p in current}

    manifests = []
    stale = []
    for did in sorted(os.listdir(docs_dir)) if os.path.isdir(docs_dir) else []:
        mp = os.path.join(docs_dir, did, "manifest.json")
        if not os.path.isfile(mp):
            stale.append(did)
            continue
        try:
            with open(mp, "r", encoding="utf-8") as fh:
                m = json.load(fh)
        except (OSError, json.JSONDecodeError):
            stale.append(did)
            continue
        if did not in current_ids or m.get("doc_id") != did:
            stale.append(did)
            continue
        manifests.append(m)

    for did in stale:
        if not args.keep_stale:
            shutil.rmtree(os.path.join(docs_dir, did), ignore_errors=True)

    manifests.sort(key=lambda m: m["source_path"])

    # statuses that actually produced page/full text artifacts
    def has_text(m):
        return m.get("extraction_status") in ("ok", "partial", "text_sparse", "ocr_failed")

    documents = []
    for m in manifests:
        u = urls_for(m["source_path"], m["doc_id"])
        if not has_text(m):
            # never advertise text URLs for docs without extracted text
            for k in ("ai_full_text_url", "ai_full_html_url",
                      "ai_pages_base_url", "ai_blocks_base_url"):
                u[k] = None
        documents.append({
            "title": m.get("title", m["filename"]),
            "display_title": m.get("display_title", m["filename"]),
            "filename": m["filename"],
            "source_path": m["source_path"],
            "doc_id": m["doc_id"],
            "pdf_page_count": m.get("pdf_page_count", 0),
            "source_sha256": m.get("source_sha256", ""),
            "extraction_status": m.get("extraction_status", "error"),
            "embedded_page_count": m.get("embedded_page_count", 0),
            "ocr_page_count": m.get("ocr_page_count", 0),
            "mixed_page_count": m.get("mixed_page_count", 0),
            "empty_page_count": m.get("empty_page_count", 0),
            "error_pages": m.get("error_pages", 0),
            "sparse_pages": m.get("sparse_pages", 0),
            "text_char_count": m.get("text_char_count", 0),
            **u,
        })

    agg = _aggregate(manifests)
    ai_bytes = _dir_size(docs_dir)
    index = {
        "schema_version": 1,
        "repository": REPOSITORY,
        "branch": REPO_BRANCH,
        "commit_sha": COMMIT_SHA,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "generator": GENERATOR,
        "pages_base_url": PAGES_BASE_URL,
        "usage_url": f"{PAGES_BASE_URL}/ai/AI_USAGE.txt",
        "human_entry": PAGES_BASE_URL + "/",
        "statistics": {
            "document_count": len(documents),
            "total_pdf_pages": agg["pages"],
            "embedded_pages": agg["embedded"],
            "ocr_pages": agg["ocr"],
            "mixed_pages": agg["mixed"],
            "empty_pages": agg["none"],
            "error_pages": agg["error_pages"],
            "status_histogram": agg["statuses"],
            "ai_docs_total_bytes": ai_bytes,
        },
        "documents": documents,
    }
    with open(os.path.join(out_dir, "index.json"), "w", encoding="utf-8") as fh:
        json.dump(index, fh, ensure_ascii=False, indent=1)

    _write_index_html(out_dir, index)
    _write_ai_usage(out_dir, index)

    print(f"[combine] documents: {len(documents)} (removed stale: {len(stale)})")
    print(f"[combine] statuses : {agg['statuses']}")
    print(f"[combine] pages    : {agg['pages']} "
          f"(embedded {agg['embedded']} / ocr {agg['ocr']} / mixed {agg['mixed']} / "
          f"none {agg['none']} / error {agg['error_pages']})")
    print(f"[combine] ai docs size: {ai_bytes / 1e6:.1f} MB")
    print(f"[combine] wrote index.json / index.html / AI_USAGE.txt in {out_dir}")
    return 0


def _dir_size(path):
    total = 0
    for dp, _, fns in os.walk(path):
        for f in fns:
            try:
                total += os.path.getsize(os.path.join(dp, f))
            except OSError:
                pass
    return total


def _write_index_html(out_dir, index):
    s = index["statistics"]
    rows = []
    for d in index["documents"]:
        st = d["extraction_status"]
        counts = (f"{d['embedded_page_count']} / {d['ocr_page_count']} / "
                  f"{d['mixed_page_count']}")
        links = []
        if d.get("ai_full_text_url"):
            links.append(f'<a href="docs/{d["doc_id"]}/full.txt">TXT</a>')
            links.append(f'<a href="docs/{d["doc_id"]}/full.html">HTML</a>')
        links.append(f'<a href="docs/{d["doc_id"]}/manifest.json">manifest</a>')
        if d.get("original_raw_url"):
            links.append(f'<a href="{d["original_raw_url"]}">PDF</a>')
            links.append(f'<a href="{d["viewer_url"]}">Viewer</a>')
        rows.append(
            f"<tr data-search=\"{html_mod.escape((d['title'] + ' ' + d['source_path']).lower())}\">"
            f'<td class="t">{html_mod.escape(d["title"])}<br>'
            f'<span class="p">{html_mod.escape(d["source_path"])}</span></td>'
            f'<td>{d["pdf_page_count"]}</td>'
            f'<td><span class="badge {st}">{st}</span></td>'
            f"<td>{counts}</td>"
            f'<td>{" · ".join(links)}</td></tr>')
    doc = (INDEX_HTML_HEAD
           + f'<div class="stats">'
           + f'<div class="stat"><div class="n">{index["statistics"]["document_count"]}</div><div class="l">文档</div></div>'
           + f'<div class="stat"><div class="n">{s["total_pdf_pages"]}</div><div class="l">PDF 页</div></div>'
           + f'<div class="stat"><div class="n">{s["embedded_pages"]}</div><div class="l">embedded 页</div></div>'
           + f'<div class="stat"><div class="n">{s["ocr_pages"] + s["mixed_pages"]}</div><div class="l">OCR/mixed 页</div></div>'
           + f'<div class="stat"><div class="n">{s["ai_docs_total_bytes"] / 1e6:.0f} MB</div><div class="l">文本总量</div></div></div>'
           + '<div class="pill">📦 <a href="index.json">index.json</a>（机器入口）</div>'
           + '<div class="pill">📄 <a href="AI_USAGE.txt">AI_USAGE.txt</a></div>'
           + '<div class="pill">📘 <a href="../">PDF.js 文档中心（人读）</a></div>'
           + '<input id="q" type="search" placeholder="可选：客户端过滤（无 JS 也能看到全部列表）">'
           + '<table><thead><tr><th>文档 / 路径</th><th>页数</th><th>状态</th>'
           + '<th>embedded/ocr/mixed</th><th>链接</th></tr></thead><tbody>'
           + "\n".join(rows)
           + "</tbody></table>"
           + '<div class="foot">TEXT_SOURCE 语义见 <code>AI_USAGE.txt</code>。'
           + 'OCR/mixed 页文本由 Tesseract (chi_sim+eng) 本地识别，仅供搜索与定位；'
           + 'Pin、IOSTANDARD、寄存器地址、bit、频率、公式等关键事实必须回原 PDF 复核。</div>'
           + '<script>document.getElementById("q").addEventListener("input",function(){'
           + 'var v=this.value.toLowerCase();document.querySelectorAll("tbody tr").forEach(function(tr){'
           + 'tr.style.display=tr.getAttribute("data-search").indexOf(v)>-1?"":"none"})});</script>'
           + "</div></body></html>\n")
    with open(os.path.join(out_dir, "index.html"), "w", encoding="utf-8") as fh:
        fh.write(doc)


def _write_ai_usage(out_dir, index):
    s = index["statistics"]
    lines = [
        "AI_USAGE — AX7035B Learning Materials · AI Web Chat Reading Path",
        "=" * 72,
        "",
        "This plain-text file tells web chat AIs (ChatGPT / Gemini / DeepSeek / ...)",
        "how to read PDF content from this repository WITHOUT downloading raw PDFs",
        "or executing PDF.js.",
        "",
        "MACHINE ENTRY (fetch this first):",
        f"  {PAGES_BASE_URL}/ai/index.json",
        "",
        "ROUTING:",
        "  1. GET /ai/index.json",
        "  2. Match a document by `title`, `display_title`, `filename` or",
        "     `source_path` (Chinese titles included; substring match is fine).",
        "  3. Then fetch, depending on the task:",
        "        <doc>.ai_full_text_url   whole document text, per-page marked",
        "        <doc>.ai_full_html_url   same content as HTML",
        "        <doc>.ai_pages_base_url  /0001.txt per physical page (1-based)",
        "        <doc>.ai_blocks_base_url /0001.json per-page text blocks + bboxes",
        "        <doc>.manifest_url       extraction manifest (proof metadata)",
        "",
        "PAGE NUMBERING: PDF_PAGE is the 1-based PHYSICAL page in the PDF file",
        "(exactly what the PDF.js viewer shows), NOT the printed textbook page number.",
        "",
        "TEXT_SOURCE per page: embedded | ocr | mixed | none | error",
        "  embedded = text layer from the PDF itself (high confidence)",
        "  ocr      = Tesseract 4/5, chi_sim+eng, ~300 DPI (search/locate only)",
        "  mixed    = embedded text + OCR overlay combined",
        "  none     = blank / decorative page (no OCR forced)",
        "",
        "EVIDENCE RULES (FPGA specifics):",
        "  OCR text is suitable for search, locating sections and general reading.",
        "  Pins, IOSTANDARDs, register addresses, bits, chip models, clock rates,",
        "  numbers, formulas, HDL snippets, schematic wiring and tables from OCR",
        "  pages MUST be re-verified against the original PDF (original_raw_url)",
        "  or the real project files (XDC/XCI/XPR/RTL in the repository).",
        "  Blocks/manifests may say contains_images=true; that does NOT mean the",
        "  electrical connections, timing or schematic topology were understood.",
        "",
        "FAILURE RULES:",
        "  - If /ai/index.json or a derived text file is missing / unreachable,",
        "    REPORT IT explicitly. Do NOT substitute content from web search.",
        "  - lfs_not_materialized: the source PDF is a Git-LFS pointer in this",
        "    build; its text is not extracted on purpose. Report the limitation.",
        "",
        "HUMANS should keep using the PDF.js viewer:",
        f"  {PAGES_BASE_URL}/",
        "",
        "CURRENT BUILD:",
        f"  documents: {index['statistics']['document_count']}  "
        f"pdf pages: {s['total_pdf_pages']}  "
        f"(embedded {s['embedded_pages']} / ocr {s['ocr_pages']} / mixed {s['mixed_pages']} / "
        f"none {s['empty_pages']} / error {s['error_pages']})",
        f"  status histogram: {json.dumps(s['status_histogram'], ensure_ascii=False)}",
        f"  generated_at: {index['generated_at']}  commit: {index['commit_sha']}",
    ]
    with open(os.path.join(out_dir, "AI_USAGE.txt"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


# --------------------------------------------------------------------------
# cachekey subcommand (stable cache key from the current PDF list + HEAD sha)
# --------------------------------------------------------------------------

def cmd_cachekey(args):
    root = os.path.abspath(args.root)
    docs = find_pdf_files(root)
    h = hashlib.sha256()
    for p in docs:
        h.update(p.encode("utf-8"))
        h.update(b"\0")
    h.update((os.environ.get("GITHUB_SHA") or COMMIT_SHA).encode())
    print(h.hexdigest()[:16])
    return 0


# --------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    b = sub.add_parser("build", help="extract AI docs (per chunk)")
    b.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    b.add_argument("--out", default=os.environ.get("AI_OUT_DIR", None) or
                   os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "viewer", "ai"))
    b.add_argument("--chunk", default=None, help="I/N e.g. 0/8 (default: all)")
    b.add_argument("--only", action="append", help="substring filter on path (repeatable)")
    b.add_argument("--force", action="store_true", help="ignore cache reuse")
    b.add_argument("--max-ocr-pages", type=int, default=None,
                   help="cap OCR pages per doc (testing only)")
    b.add_argument("--workers", type=int, default=WORKERS_DEFAULT)
    b.add_argument("--dry-run", action="store_true",
                   help="classify pages only; write nothing")
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("combine", help="merge manifests -> index.json/index.html/AI_USAGE.txt")
    c.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    c.add_argument("--out", default=os.environ.get("AI_OUT_DIR", None) or
                   os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "viewer", "ai"))
    c.add_argument("--keep-stale", action="store_true")
    c.set_defaults(func=cmd_combine)

    k = sub.add_parser("cachekey", help="print stable cache key for current PDF list")
    k.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    k.set_defaults(func=cmd_cachekey)

    args = ap.parse_args()
    sys.exit(args.func(args))


if __name__ == "__main__":
    main()
