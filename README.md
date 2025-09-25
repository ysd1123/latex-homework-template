# LaTeX Homework Template (ctex fork)

本仓库在原始模板的基础上进行了最小必要的改动，主要目标是在保持原有排版风格的同时
增加 XeLaTeX/`ctex` 的中文支持、可选的版式和字体配置，并将模板逻辑抽离成独立的
`homework` 文档类，方便专注于正文编写。

## 目录结构

- `homework.cls`：统一的文档类，封装排版、页眉页脚、题目环境、可选的字体/行距/页边距
  调整等功能。
- `homework_en.tex`：英文示例正文，沿用原模板的排版示例。
- `homework_zh-CN.tex`：中文示例正文，演示 `ctex` 中文支持及可选的中文标题等写法。
- `images/`：沿用上游仓库的示意图片资源。

## 主要改动

1. **新增 `homework.cls` 文档类**：将原本写在 `homework.tex` 中的排版与宏命令集中到
   文档类中。正文文件仅需引入 `\documentclass{homework}` 并设置作业元数据。
2. **默认启用 `ctex`（`scheme=plain`）**：确保中文内容在 XeLaTeX 下直接可用，同时尽量
   不干扰原有的英文字体设定。
3. **可选的字体与版式接口**（默认关闭，示例以注释形式给出）：
   - `\homeworksetlinespread{...}` 调整全文行距；
   - `\homeworksetmargins{...}` 通过 `geometry` 重新设定页边距；
   - `\homeworksetproblemtitlespacing{...}{...}` 控制 “Problem” 章节上下间距；
   - `\homeworksetsolutionskip{...}{...}` 控制 `\solution` 标题前后的垂直间距；
   - `\homeworksetCJKmainfont`、`\homeworksetmainfont` 等命令用于设置中文/西文字体；
   - `\homeworksetmathfont` 会在需要时自动载入 `unicode-math`，用于指定数学字体。
4. **提供中英文两份正文模板**：分别演示英文排版与中文排版的使用方式，其中中文模板也给
   出了如何将 `Solution` 标题替换为“解答”的注释示例。
5. **更新 `README.md`**：说明本分支的改动、使用方法以及与上游仓库的差异。

## 使用方法

1. 建议使用 TeX Live 2025 及 XeLaTeX（或 LuaLaTeX），以获得完整的 `ctex` 与字体支持。
2. 在命令行中使用 `latexmk` 进行自动编译，例如：

   ```bash
   latexmk -xelatex homework_en.tex
   latexmk -xelatex homework_zh-CN.tex
   ```

3. 若需要自定义版式或字体，可在正文文件中取消对应注释并填入所需参数。例如：

   ```latex
   % \homeworksetmargins{left=25mm,right=25mm,top=22mm,bottom=25mm}
   % \homeworksetCJKmainfont{Source Han Serif SC}
   % \homeworksetmathfont{XITS Math}
   ```

   需要注意：
   - 指定数学字体时需确保系统已安装该字体；
   - `\homeworksetmathfont` 会加载 `unicode-math`，与传统的 `mathptmx` 等方案不同。

4. 中文模板中如果希望将 `Solution` 改为“解答”，可按照文件中给出的注释进行 `\renewcommand`。

## 许可协议

本仓库继续沿用上游模板的 [MIT 许可证](LICENSE)。
