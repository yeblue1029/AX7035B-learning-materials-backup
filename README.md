# AX7035B Learning Materials

AX7035B FPGA 开发板学习资料、实验工程、原理图、芯片资料与学习笔记。

## 仓库用途

- 整理 AX7035B 开发板学习资料
- 保存可直接浏览的 HDL 源码、工程文件和约束文件
- 便于按照实验目录向 AI 提问和排查工程问题
- 记录实验目的、硬件连接、构建步骤和实验现象

## 🤖 Web Chat AI 文档读取

普通网页聊天 AI（ChatGPT / Gemini / DeepSeek 等）读取 PDF 正文时，**优先使用 AI Reading Path**（纯文本，无需执行 PDF.js 或解析二进制），不要默认先撞 raw PDF。

- **Web Chat AI 阅读入口（Web Chat AI 从这里开始）**：[AI Reading Path](https://yeblue1029.github.io/AX7035B-learning-materials-backup/ai/) — 打开后**只沿页面真实链接继续**：文档标题 → 文档页（landing）→ `full.txt` / `pages` / `blocks`
- 机器 JSON 接口（Agent / script API；供支持任意 URL fetch 的 Agent / 脚本使用，**非 Web Chat AI 首选入口**）：[index.json](https://yeblue1029.github.io/AX7035B-learning-materials-backup/ai/index.json)
- AI 使用说明：[AI_USAGE.txt](https://yeblue1029.github.io/AX7035B-learning-materials-backup/ai/AI_USAGE.txt)
- 完整路由与证据规则：[AI_ACCESS.md](AI_ACCESS.md)

网页聊天 AI 受 safe-to-open 策略限制（只能打开出现在先前页面或用户消息中的 URL），因此应**沿上述 HTML 页面中的真实 `<a href>` 链接逐跳点击导航**，不需要根据 JSON 字符串自行拼接或打开新 URL。

raw PDF 保留为 **Agent / 脚本 / 证据复核（Source Evidence）** 路径；派生文本与原 PDF 冲突时以原 PDF 为准。

## 内容整理原则

- 优先上传已经解压的源码和工程目录
- 不重复上传已有解压内容的 ZIP、RAR 和 7Z 压缩包
- 不上传许可证、密钥、破解工具和私人配置
- 不上传可重新生成的 Vivado、ISE 和编译输出
- 第三方资料在确认公开再分发许可后再上传

## 📚 PDF 在线文档

仓库内全部 PDF 都可以在浏览器中直接在线阅读（翻页 / 缩放 / 文本搜索 / 缩略图 / 下载 / 打印），同时为每个文档保留可被云端 AI 与脚本直接获取的**原始 PDF 链接**。

**📖 PDF 文档中心**（自动索引全部 183 个 PDF，可搜索 / 按目录分类）：

https://yeblue1029.github.io/AX7035B-learning-materials-backup/

示例在线阅读（基于 Mozilla PDF.js，跨域读取 GitHub raw，无需登录）：

- 📖 [AX7035 开发板用户手册 REV1.1](https://yeblue1029.github.io/AX7035B-learning-materials-backup/web/viewer.html?file=https%3A%2F%2Fraw.githubusercontent.com%2Fyeblue1029%2FAX7035B-learning-materials-backup%2Fmain%2FAX7035%25E5%25BC%2580%25E5%258F%2591%25E6%259D%25BF%25E7%2594%25A8%25E6%2588%25B7%25E6%2589%258B%25E5%2586%258CREV1.1.pdf)
- 📖 [vivado 下 LED 流水灯实验及仿真](https://yeblue1029.github.io/AX7035B-learning-materials-backup/web/viewer.html?file=https%3A%2F%2Fraw.githubusercontent.com%2Fyeblue1029%2FAX7035B-learning-materials-backup%2Fmain%2F01_demo_document%2F%25E5%25AE%259E%25E9%25AA%258C%25E6%2595%2599%25E7%25A8%258B%2F%25E5%25AE%259E%25E9%25AA%258C%25E6%2595%2599%25E7%25A8%258B%2F01.vivado%25E4%25B8%258BLED%25E6%25B5%2581%25E6%25B0%25B4%25E7%2581%25AF%25E5%25AE%259E%25E9%25AA%258C%25E5%258F%258A%25E4%25BB%25BF%25E7%259C%259F.pdf)
- 📖 [Artix-7 Data Sheet (ds181)](https://yeblue1029.github.io/AX7035B-learning-materials-backup/web/viewer.html?file=https%3A%2F%2Fraw.githubusercontent.com%2Fyeblue1029%2FAX7035B-learning-materials-backup%2Fmain%2F05_%25E8%258A%25AF%25E7%2589%2587%25E6%2589%258B%25E5%2586%258C%2FArtix-7%2Fds181_Artix_7_Data_Sheet.pdf)

**🤖 AI / 脚本获取原始 PDF**：每个 PDF 的原始文件托管在 `raw.githubusercontent.com`，无需 JavaScript 即可经 HTTP 获取，返回真实 PDF 二进制（已开启 CORS、支持 Range 分段请求）：

```bash
curl -L "https://raw.githubusercontent.com/yeblue1029/AX7035B-learning-materials-backup/main/AX7035%E5%BC%80%E5%8F%91%E6%9D%BF%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8CREV1.1.pdf" -o manual.pdf
file manual.pdf   # -> PDF document
```

完整清单见 [`viewer/pdf-index.json`](viewer/pdf-index.json)，包含每个 PDF 的 `viewer_url` / `raw_url` / `github_url`。架构与维护说明见 [`viewer/MAINTENANCE.md`](viewer/MAINTENANCE.md)。

> 注：Git-LFS 跟踪的 2 个大文件（带 `LFS` 标记）的 `raw` 返回的是 LFS 指针而非 PDF，详见 MAINTENANCE.md 的「已知限制」。

## AI-Assisted Learning

This repository includes AI navigation and learning assistance:

- **`AI_REPO_INDEX/`** — Repository navigation index. Use it to find demos, projects, constraints, IP cores, and key files. The index is a navigation layer, not the source of truth. Always open actual files to verify facts.

- **`.trae/skills/ax7035b-learning/SKILL.md`** — TRAE project-level AX7035B learning skill. Provides evidence-first workflow for learning, development, and debugging.

To regenerate the index:
```
.trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.cmd
```

Vivado generated build outputs (*.runs, *.cache, *.hw, *.sim, *.gen, ip_user_files) are intentionally excluded from tracking. Learning should prioritize: tutorial → XPR → XDC → top RTL → IP configuration → board manual/datasheet.

## 当前状态

仓库正在根据本地扫描结果分阶段整理和上传。

## 版权说明

各文件版权归相应作者或厂商所有。技术上可以提交到 GitHub，不代表已经取得公开再分发许可；授权状态不明确的资料应暂缓公开。
