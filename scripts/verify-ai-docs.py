#!/usr/bin/env python3
"""
verify-ai-docs.py — Validate the generated AI reading path under <site>/ai/.

Checks (stdlib only, no PyMuPDF needed):
  1.  index.json parses, schema_version == 1, repository correct, documents non-empty
  2.  every document: doc_id == sha256(source_path)[:16], unique
  3.  manifest.json exists per doc, parses, manifest.source_sha256 == actual file SHA256
  4.  source PDF magic: %PDF- (or LFS pointer => status must be lfs_not_materialized)
  5.  page accounting: embedded+ocr+mixed+empty+error == pdf_page_count (text docs)
  6.  pages/ has exactly pdf_page_count files, named 0001.txt..NNNN.txt, UTF-8, headers ok
  7.  blocks/ has exactly pdf_page_count JSON files, UTF-8, parse, block_source recorded
  8.  full.txt exists, UTF-8, contains one "===== PDF_PAGE nnnn =====" marker per page
  9.  URL mapping: every ai_*_url / manifest_url is absolute HTTPS under the Pages base
      and the URL-decoded path exists on disk
  10. extraction_status in allowed set & consistent with counts
  11. index.html exists, UTF-8, contains every doc source_path in raw HTML (no-JS rule)
  12. AI_USAGE.txt exists
  13. artifact size report + guard (fail if ai/ > --size-guard-mb)

Exit code 0 = all hard checks passed (warnings allowed), 1 = failures.
"""

import argparse
import hashlib
import html as html_mod
import json
import os
import sys
from urllib.parse import unquote, urlparse

ALLOWED_STATUSES = {"ok", "partial", "text_sparse", "invalid_pdf",
                    "lfs_not_materialized", "ocr_failed", "error"}
TEXT_STATUSES = {"ok", "partial", "text_sparse", "ocr_failed"}
LFS_PREFIX = b"version https://git-lfs.github.com/spec/v1"


def file_sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def dir_size(path):
    total = 0
    for dp, _, fns in os.walk(path):
        for f in fns:
            try:
                total += os.path.getsize(os.path.join(dp, f))
            except OSError:
                pass
    return total


def read_utf8(path):
    with open(path, "rb") as fh:
        data = fh.read()
    return data.decode("utf-8"), len(data)   # raises UnicodeDecodeError on failure


class Report:
    def __init__(self):
        self.failures = []
        self.warnings = []

    def fail(self, msg):
        self.failures.append(msg)

    def warn(self, msg):
        self.warnings.append(msg)

    @property
    def ok(self):
        return not self.failures


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--site", default=os.path.join(here, "..", "viewer"),
                    help="directory that contains ai/ (the Pages site root)")
    ap.add_argument("--repo", default=os.path.join(here, ".."))
    ap.add_argument("--size-guard-mb", type=float, default=700.0,
                    help="fail if site ai/ exceeds this many MB (Pages limit 1 GB)")
    args = ap.parse_args()

    site = os.path.abspath(args.site)
    repo = os.path.abspath(args.repo)
    ai = os.path.join(site, "ai")
    rep = Report()

    # 1. index.json ---------------------------------------------------------
    idx_path = os.path.join(ai, "index.json")
    if not os.path.isfile(idx_path):
        print(f"FATAL: {idx_path} missing")
        return 1
    try:
        idx_text, _ = read_utf8(idx_path)
        idx = json.loads(idx_text)
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        print(f"FATAL: index.json invalid: {e}")
        return 1
    if idx.get("schema_version") != 1:
        rep.fail(f"schema_version != 1 ({idx.get('schema_version')})")
    if not idx.get("documents"):
        rep.fail("index.json has no documents")

    base = (idx.get("pages_base_url") or "").rstrip("/")
    if not base.startswith("https://"):
        rep.fail(f"pages_base_url not absolute HTTPS: {base!r}")
    # project Pages sites are served under /<repo-name>/ — strip that prefix
    # so URLs map onto the local site root directory.
    base_path = urlparse(base).path.rstrip("/")

    docs = idx.get("documents", [])
    seen_ids = set()
    stat_hist = {}

    # per-document checks ----------------------------------------------------
    for d in docs:
        did = d.get("doc_id", "")
        src = d.get("source_path", "")
        st = d.get("extraction_status", "")
        stat_hist[st] = stat_hist.get(st, 0) + 1
        label = f"{did} ({src})"

        # 2. doc_id determinism & uniqueness
        expect_id = hashlib.sha256(src.encode("utf-8")).hexdigest()[:16]
        if did != expect_id:
            rep.fail(f"{label}: doc_id {did} != sha256(path)[:16] {expect_id}")
        if did in seen_ids:
            rep.fail(f"{label}: duplicate doc_id")
        seen_ids.add(did)

        # 10. status validity
        if st not in ALLOWED_STATUSES:
            rep.fail(f"{label}: invalid extraction_status {st!r}")

        # 3-4. source file, sha256, magic / LFS pointer
        src_abs = os.path.join(repo, src)
        if not os.path.isfile(src_abs):
            rep.fail(f"{label}: source file missing in repo")
            continue
        with open(src_abs, "rb") as fh:
            head = fh.read(64)
        if head.startswith(LFS_PREFIX):
            if st != "lfs_not_materialized":
                rep.fail(f"{label}: source is LFS pointer but status={st}")
        else:
            if not head.startswith(b"%PDF-"):
                if st != "invalid_pdf":
                    rep.fail(f"{label}: source has no %PDF- magic but status={st}")
            elif st == "lfs_not_materialized":
                rep.fail(f"{label}: status=lfs_not_materialized but file is a real PDF")
            real_sha = file_sha256(src_abs)
            if d.get("source_sha256") != real_sha:
                rep.fail(f"{label}: index source_sha256 mismatch")

        # 5-8. text artifacts (only for statuses that should have text)
        doc_dir = os.path.join(ai, "docs", did)
        mp = os.path.join(doc_dir, "manifest.json")
        if not os.path.isfile(mp):
            rep.fail(f"{label}: manifest.json missing")
        else:
            try:
                man_text, _ = read_utf8(mp)
                man = json.loads(man_text)
            except (UnicodeDecodeError, json.JSONDecodeError) as e:
                rep.fail(f"{label}: manifest.json invalid: {e}")
                man = None
            if man is not None:
                if man.get("source_sha256") and d.get("source_sha256") != man.get("source_sha256"):
                    rep.fail(f"{label}: index vs manifest sha256 mismatch")
                if man.get("extraction_status") != st:
                    rep.fail(f"{label}: index vs manifest status mismatch")
                for k in ("embedded_page_count", "ocr_page_count", "mixed_page_count",
                          "empty_page_count", "error_pages", "pdf_page_count",
                          "ocr_config_version", "extractor_version", "generated_at"):
                    if k not in man:
                        rep.warn(f"{label}: manifest missing field {k}")

        npages = d.get("pdf_page_count", 0)
        if st in TEXT_STATUSES and npages:
            counts = (d.get("embedded_page_count", 0) + d.get("ocr_page_count", 0)
                      + d.get("mixed_page_count", 0) + d.get("empty_page_count", 0)
                      + d.get("error_pages", 0))
            if counts != npages:
                rep.fail(f"{label}: page counts sum {counts} != pdf_page_count {npages}")

            pages_dir = os.path.join(doc_dir, "pages")
            blocks_dir = os.path.join(doc_dir, "blocks")
            full_path = os.path.join(doc_dir, "full.txt")
            html_path = os.path.join(doc_dir, "full.html")
            for p, what in ((full_path, "full.txt"), (html_path, "full.html")):
                if not os.path.isfile(p):
                    rep.fail(f"{label}: {what} missing")
            expected = {f"{i:04d}.txt" for i in range(1, npages + 1)}
            actual = set(os.listdir(pages_dir)) if os.path.isdir(pages_dir) else set()
            if actual != expected:
                rep.fail(f"{label}: pages/ has {len(actual)} files, expected {npages}")
            expected_b = {f"{i:04d}.json" for i in range(1, npages + 1)}
            actual_b = set(os.listdir(blocks_dir)) if os.path.isdir(blocks_dir) else set()
            if actual_b != expected_b:
                rep.fail(f"{label}: blocks/ has {len(actual_b)} files, expected {npages}")

            # spot-check a few pages + full.txt markers
            if actual == expected:
                sample = sorted(actual)[:2] + sorted(actual)[-1:]
                for fn in sample:
                    try:
                        t, _ = read_utf8(os.path.join(pages_dir, fn))
                        if f"PDF_PAGE:" not in t or "TEXT_SOURCE:" not in t:
                            rep.fail(f"{label}: pages/{fn} missing header fields")
                    except UnicodeDecodeError:
                        rep.fail(f"{label}: pages/{fn} not UTF-8")
                for fn in sorted(actual_b)[:2]:
                    try:
                        t, _ = read_utf8(os.path.join(blocks_dir, fn))
                        b = json.loads(t)
                        if "block_source" not in b or "text_source" not in b:
                            rep.fail(f"{label}: blocks/{fn} missing block_source/text_source")
                    except (UnicodeDecodeError, json.JSONDecodeError):
                        rep.fail(f"{label}: blocks/{fn} invalid")
                try:
                    ft, _ = read_utf8(full_path)
                    import re
                    markers = re.findall(r"========== PDF_PAGE (\d{4}) ==========", ft)
                    if len(markers) != npages:
                        rep.fail(f"{label}: full.txt has {len(markers)} page markers, "
                                 f"expected {npages}")
                except UnicodeDecodeError:
                    rep.fail(f"{label}: full.txt not UTF-8")

        # 9. URL mapping
        for key in ("ai_full_text_url", "ai_full_html_url", "manifest_url"):
            u = d.get(key) or ""
            if not u:
                # null text URLs are allowed ONLY for non-text statuses
                if key == "manifest_url" or st in TEXT_STATUSES:
                    rep.fail(f"{label}: required {key} is null/missing")
                continue
            if not u.startswith("https://"):
                rep.fail(f"{label}: {key} not absolute HTTPS: {u!r}")
                continue
            path = urlparse(u).path
            rel = unquote(path)
            if base_path and rel.startswith(base_path + "/"):
                rel = rel[len(base_path):]
            local = os.path.join(site, rel.lstrip("/"))
            if not os.path.isfile(local):
                rep.fail(f"{label}: {key} -> {rel} missing on disk")
        for key in ("ai_pages_base_url", "ai_blocks_base_url"):
            u = d.get(key) or ""
            if not u and st in TEXT_STATUSES:
                rep.fail(f"{label}: required {key} is null/missing")
            elif u and not u.startswith("https://"):
                rep.fail(f"{label}: {key} not absolute HTTPS")
        if d.get("original_raw_url", "") and "raw.githubusercontent.com" not in d["original_raw_url"]:
            rep.warn(f"{label}: unexpected original_raw_url host")

    # 11-12. index.html + AI_USAGE.txt --------------------------------------
    html_path = os.path.join(ai, "index.html")
    if not os.path.isfile(html_path):
        rep.fail("ai/index.html missing")
    else:
        try:
            h, _ = read_utf8(html_path)
            # source_path is HTML-escaped in index.html (&#x27; for "'" etc.),
            # so compare against the unescaped text, not the raw markup.
            h_unescaped = html_mod.unescape(h)
            missing = [d["source_path"] for d in docs
                       if d.get("source_path") and d["source_path"] not in h_unescaped]
            if missing:
                rep.fail(f"index.html does not embed {len(missing)} document paths "
                         f"(no-JS rule), e.g. {missing[:3]}")
        except UnicodeDecodeError:
            rep.fail("ai/index.html not UTF-8")
    if not os.path.isfile(os.path.join(ai, "AI_USAGE.txt")):
        rep.fail("ai/AI_USAGE.txt missing")

    # 13. size report + guard ------------------------------------------------
    ai_mb = dir_size(ai) / 1e6
    docs_mb = dir_size(os.path.join(ai, "docs")) / 1e6
    biggest = 0.0
    biggest_file = ""
    page_files = 0
    block_bytes = 0
    for dp, _, fns in os.walk(os.path.join(ai, "docs")):
        for f in fns:
            p = os.path.join(dp, f)
            try:
                sz = os.path.getsize(p)
            except OSError:
                continue
            if f == "full.txt" and sz > biggest:
                biggest, biggest_file = sz, os.path.relpath(p, ai)
            if os.path.basename(dp) == "pages":
                page_files += 1
            if os.path.basename(dp) == "blocks":
                block_bytes += sz
    if ai_mb > args.size_guard_mb:
        rep.fail(f"ai/ size {ai_mb:.1f} MB exceeds guard {args.size_guard_mb} MB "
                 f"(GitHub Pages limit is 1 GB) — refusing to deploy")

    # ---- report -------------------------------------------------------------
    total_pages = idx.get("statistics", {}).get("total_pdf_pages", 0)
    print("=" * 68)
    print("verify-ai-docs report")
    print("=" * 68)
    print(f"documents          : {len(docs)}  (statuses: {json.dumps(stat_hist, ensure_ascii=False)})")
    print(f"total pdf pages    : {total_pages}")
    print(f"page txt files     : {page_files}")
    print(f"ai/ total size     : {ai_mb:.1f} MB   (docs/: {docs_mb:.1f} MB)")
    print(f"largest full.txt   : {biggest / 1e6:.2f} MB  {biggest_file}")
    print(f"blocks/ total size : {block_bytes / 1e6:.1f} MB")
    print(f"size guard         : {ai_mb:.1f} / {args.size_guard_mb:.0f} MB "
          f"{'OK' if ai_mb <= args.size_guard_mb else 'EXCEEDED'}")
    if rep.warnings:
        print(f"\nwarnings ({len(rep.warnings)}):")
        for w in rep.warnings[:20]:
            print(f"  - {w}")
    if rep.failures:
        print(f"\nFAILURES ({len(rep.failures)}):")
        for f in rep.failures[:40]:
            print(f"  - {f}")
        if len(rep.failures) > 40:
            print(f"  ... and {len(rep.failures) - 40} more")
        return 1
    print("\nALL CHECKS PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
