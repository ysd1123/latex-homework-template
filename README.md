# LaTeX Homework Template（带中文支持的作业文档类）

这个仓库提供了一个独立的 `homework` 文档类，帮助你快速创建中英文双语作业、讲义或练习册。
我们在原始模板基础上系统升级：支持 `lang` 语言选项、统一的题目／子题环境、丰富的定制接口，
并在 XeLaTeX（TeX Live 2025）中开箱即用。

如果你只是希望“拉起一个作业模板并开始写内容”，直接参考 `homework_zh-CN.tex`（中文）或
`homework_en.tex`（英文）即可；它们互为镜像示例，展示了所有推荐功能。

---

## 目录结构与快速上手

| 路径 | 说明 |
| --- | --- |
| `homework.cls` | 核心文档类。负责解析选项、加载依赖、定义题目环境、宏命令等 |
| `homework_zh-CN.tex` | 推荐的中文示例文档（`lang=zh`），演示所有主要特性 |
| `homework_en.tex` | 推荐的英文示例文档（`lang=en`），内容与中文版本完全对称 |
| `images/`、`latex-homework-template/test/` | 示例插图或演示资料，可按需忽略 |

> ⚙️ **最短上手步骤**
> 1. 安装 TeX Live 2025（或更新版本）并确保使用 XeLaTeX。
> 2. `latexmk -xelatex homework_zh-CN.tex` 或 `latexmk -xelatex homework_en.tex`。
> 3. 根据示例文件改写元信息、题目内容即可。

---

## `homework` 文档类：选项、宏与环境一览

### 语言与字体选项

| 选项 | 取值 | 作用 |
| --- | --- | --- |
| `lang` | `zh` / `zh-plain` / `en`（默认） | 决定底层类（`ctexart` or `article`）、中文支持、默认标签 |
| `chinesenumbering` | 布尔 | 题目／子题编号切换为中文序数（需 `lang=zh` 或 `zh-plain`） |
| `localizedate` | 布尔 | 覆盖 `	oday` 输出。`zh` 系语言显示“YYYY年MM月DD日”，英文用 ISO（YYYY-MM-DD） |

字体接口：

- `ase`：直接用 `fontspec`
  - `	exttt{	extbackslash homeworksetmainfont}` / `	exttt{	extbackslash homeworksetsansfont}` / `	exttt{	extbackslash homeworksetmonofont}`
- CJK 字体（仅 `lang=zh*` 可用）：
  - `	exttt{	extbackslash homeworksetCJKmainfont}`、`	exttt{	extbackslash homeworksetCJKsansfont}`、`	exttt{	extbackslash homeworksetCJKmonofont}`
- 数学字体：`\homeworksetmathfont`（会自动加载 `unicode-math`，须确保字体可用）

### 排版风格选项

| 选项 | 取值 / 默认 | 说明 |
| --- | --- | --- |
| `linespread` | `auto` / `tight` / `normal` / `comfort` / `loose` / 自定义 | 行距；`auto` 会根据语言和是否 `minimal` 选择 | 
| `indent` | `auto` / `none` / 长度 | 段首缩进；中文模式自动设为 `2em` |
| `tightlists` | 布尔 | 使用 `enumitem` 创建更紧凑的列表 |
| `captionstyle` | `plain` / `chinese` / `compact` / 自定义 | 调整 `caption` 样式、对齐与间距 |
| `problemstyle` | `plain` / `boxed` | 题面是否使用 `tcolorbox` 包装 |
| `theme` | `light` / `gray` / `color` + 手动颜色 | 控制盒子背景、边框颜色，可用 `problemcolor` 等覆盖 |
| `fastcompile` | 布尔 | 精简 `tcolorbox` 装饰以加快编译 |
| `minimal` | 布尔 | 关闭大部分可选增强（适用于打印或最小依赖环境） |

### 元信息与自动标签

`homework.cls` 提供以下命令，可在导言区 `
enewcommand` 设置：

```latex
\hmwkTitle             \hmwkClass            \hmwkClassTime
\hmwkClassInstructor   \hmwkAuthorName       \hmwkDueDate
\hmwkSolutionName      \hmwkProofName        \hmwkProblemName
```

此外，还可以自定义“截止日期”标签（默认 `Due Date:` 或 `截止日期：`）：

```latex
\documentclass[...,duedatelabel={提交日期：}]{homework}
```

### 题目相关环境与钩子

核心环境：

- `problem` / `problem*`：带编号或无编号题目。
- `subproblem` / `subproblem*`：子题，支持数字式（`1.1`）、字母式（`Part A`）或中文序号。
- `note`：题目内备注，默认标题为“当前题目的注记”。
- `solution`：粗体的解答标题（可自定义标题文本）。
- `proof`：沿用 `amsthm`，可配合自定义 `
enewcommand{
oofname}{...}`。

钩子 / 自定义接口：

```latex
\homeworkBeforeProblemHook   % 每题开头插入额外内容
\homeworkAfterProblemHook    % 题尾补充内容（如分隔线）
```

若需手动指定下一题标题，可使用：

```latex
\homeworksetproblemtitle{自定义标题}
```

### 数学与统计宏（可按需启用）

- `mathdelims`：定义 `	exttt{\abs}`、`	exttt{\norm}`、`	exttt{\ceil}`、`	exttt{\floor}`、`	exttt{\set}`、`	exttt{\inner}`。
- `statmacros`：依赖 `mathdelims`，将 `	exttt{\E}`、`	exttt{\Var}` 等替换为 `	extbb{E}`／`operatorname` 格式，并新增 `	exttt{\Prob}`、`	exttt{\Expect}`、`	exttt{\VarOf}`、`	exttt{\CovOf}`、`	exttt{\BiasOf}`、`	exttt{\indicator}`、`	exttt{\given}`。

---

## 示例文档说明

- **`homework_zh-CN.tex`**：使用 `lang=zh`，开启 `problemstyle=boxed`、`theme=color`、`mathdelims`、`statmacros` 等关键特性。展示了自定义钩子、子题编号、解答结构以及 `note` 环境的实际用法。
- **`homework_en.tex`**：与中文示例完全对称，只是内容语言为英文；适用于不加载 `ctex` 的纯英文课程。

两份文件均采用“推荐模板写法”，你只需要替换元信息与题目即可快速生产自己的作业文档。

---

## 编译指南

### 前置环境

- 推荐：TeX Live ≥ 2025，XeLaTeX / LuaLaTeX。
- 保证 `fontspec`、`unicode-math`、`tcolorbox`、`enumitem`、`caption`、`tikz`、`algorithm` 等宏包可用。

### 常用命令

```bash
latexmk -xelatex homework_zh-CN.tex
latexmk -xelatex homework_en.tex
```

若只需一次编译：

```bash
xelatex homework_zh-CN.tex
```

---

## 兼容性、已知限制与改进方向

> ❗ **已知问题 / 限制**
> - `lang=en` 模式下若仍传入中文字符，需要手动配置 CJK 字体（类中会提醒但不会自动处理）。
> - `mathdelims`/`statmacros` 依赖 `mathtools` 与 `unicode-math`，部分老旧模板若与之冲突需手动调整。
> - 如果你把 `homework.cls` 与旧版文档混用，可能需要清理以前自定义的 `problem` 环境以避免冲突。
> - `minimal` 选项会关闭大部分增强功能，如果与示例不一致属正常现象。

> 🚀 **未来可考虑的增强**
> - 自动化标题页布局、徽标插入等更丰富的模板元素。
> - 提供更多配色方案或主题并支持 JSON/YAML 式外部配置。
> - 提供可选的“答案册模式”，在题目后自动插入解答页。
> - 增强与 Beamer、Exam 类似文档类、或 Markdown 转 LaTeX 工具的互操作性。

---

## 旧版兼容性的注意事项

- 旧模板中的 `problem`/`problem*`、`solution` 等命令仍然可用，但建议迁移到新接口以获得语言切换、编号、主题等优势。
- 若你之前通过 `	itle{...}` 手动定义标题页，现在无需再写，类已经自动封装。旧代码若仍存在，需自行移除以避免重复。
- 任何自定义命令若希望保留，请在导言区 `
enewcommand` 对应宏（参见示例）。

---

## 许可协议

沿用原项目的 [MIT 许可证](LICENSE)。欢迎提 Issue or PR 反馈需求与建议。
