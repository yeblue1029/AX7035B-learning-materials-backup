# AI_ACCESS — 如何读取本仓库的 PDF 文档

本文件告诉各类访问者（人类、网页聊天 AI、Agent/脚本）如何正确读取本仓库中的 PDF。
原始 PDF 永远是唯一 Source of Truth，本文件描述的是**读取路径**，不是替代品。

仓库：`yeblue1029/AX7035B-learning-materials-backup`（AX7035B / XC7A35T FPGA 学习资料，183 个 PDF）

---

## 路径一：Human（人类读者）

继续使用现有 PDF.js 在线文档中心（翻页 / 缩放 / 搜索 / 缩略图）：

```
https://yeblue1029.github.io/AX7035B-learning-materials-backup/
```

无需任何改变。

---

## 路径二：Web Chat AI（ChatGPT / Gemini / DeepSeek 等）

**读取 PDF 正文时，不要默认优先使用 raw PDF。**
网页聊天 AI 通常无法可靠执行 PDF.js，也经常无法直接解析 raw PDF 二进制。
请按以下顺序访问：

### 第 1 步：读取机器索引

```
https://yeblue1029.github.io/AX7035B-learning-materials-backup/ai/index.json
```

### 第 2 步：根据以下字段定位文档

- `title`（PDF 内嵌标题）
- `display_title`（文件名去扩展名，中文原名）
- `filename`（中文文件名）
- `source_path`（仓库内相对路径）

子串匹配即可，不需要用户手工提供 `doc_id`。

### 第 3 步：按任务选择派生资源（均为绝对 HTTPS URL，直接 fetch）

| 字段 | 用途 |
|---|---|
| `ai_full_text_url` | 整本纯文本（带每页 `PDF_PAGE` / `TEXT_SOURCE` 标记） |
| `ai_full_html_url` | 同上内容的 HTML 版 |
| `ai_pages_base_url` | 单页文本：`<base>/0001.txt`（PDF 物理页，1-based） |
| `ai_blocks_base_url` | 单页文本块 + bbox：`<base>/0001.json`（辅助阅读顺序 / 图表附近定位） |
| `manifest_url` | 提取清单（SHA256、页数统计、OCR 元数据、证据等级） |

精确查询某页内容时，优先读取目标页及相邻页（`pages/NNNN.txt`）。

### 页码语义

`PDF_PAGE` 是 PDF 文件的**物理页序（1-based）**，与 PDF.js Viewer 显示一致；
不是教材自己印刷的页码。

### TEXT_SOURCE（每页证据等级）

| 值 | 含义 |
|---|---|
| `embedded` | PDF 自带文字层，可信度高 |
| `ocr` | Tesseract 本地识别（`chi_sim+eng`，约 300 DPI），仅供搜索/定位/一般阅读 |
| `mixed` | embedded 文字层 + OCR 叠加 |
| `none` | 空白页 / 装饰页（未强制 OCR） |
| `error` | 该页提取失败 |

### OCR 证据规则（FPGA 资料必读）

OCR 文本适合：搜索、定位章节、一般性阅读。
但 FPGA 文档中的 **Pin、IOSTANDARD、寄存器地址、bit 定义、芯片型号、时钟频率、
数字、公式、HDL 代码、原理图连接、表格数值**——凡来自 `ocr` / `mixed` 页，
**必须回原 PDF（`original_raw_url` / `viewer_url`）或仓库真实工程文件
（XDC / XCI / XPR / RTL）复核**，不得直接采信。

本仓库大量页面包含原理图、PCB 图、波形、时序图、Block Diagram、pinout 截图。
OCR 只识别文字。`manifest` / `blocks` 中的 `contains_images=true` 只表示页面含图，
**不代表** 已理解电气连接、信号走向、时序关系或原理图拓扑。
不得基于 OCR 文本编造上述结论。

---

## 路径三：Agent / Scripts（真正支持二进制处理的程序）

具备以下能力的 Agent / 脚本仍可直接读取原始 PDF：

- 二进制下载（curl / wget / HTTP client）
- 本地文件系统写入
- 真正的 PDF parser（PyMuPDF / pdfplumber / pdftotext 等）

```
https://raw.githubusercontent.com/yeblue1029/AX7035B-learning-materials-backup/main/<path>
```

完整原始文件清单（含每个 PDF 的 `raw_url` / `viewer_url` / `github_url`）：
`viewer/pdf-index.json`（构建产物，见 Pages 站点根目录）。
AI Reading Path 派生文本与原 PDF 冲突时，以原 PDF 为准（Source Evidence）。

---

## Failure Rule（失败规则）

出现以下情况时**明确报告**，禁止静默降级：

- `/ai/index.json` 或派生文本不存在 / 不可达（HTTP 非 200）；
- 文档状态为 `lfs_not_materialized`：源 PDF 是 Git-LFS 指针、本构建未物化，
  其文本**有意**未提取，不要把指针文字当作正文；
- `invalid_pdf` / `error` / `ocr_failed`：提取失败；
- OCR 结果明显稀疏（`text_sparse` / `sparse_pages` 高）。

**禁止通过互联网搜索同名资料补正文。**
禁止用第三方 PDF 转换服务或云 OCR API 替代。

---

## 对 FPGA 工程问题的重要提醒

AI Reading Path 只解决“PDF 可读性”。它不能代替真实工程文件。
涉及 RTL / XDC / XCI / XPR / Testbench / Tcl 的问题，必须直接读取仓库真实文件，
不得从 PDF 派生文本推测实际工程配置。
板级事实仍需 原理图 / 用户手册 / XDC / 实际 RTL 交叉验证。
