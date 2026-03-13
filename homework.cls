% 基于原版模板修改的作业（Homework）文档类
% 提供了可选的中文（ctex）支持以及可配置的排版选项
% 新增语言选项：lang = zh | zh-plain | en（默认）
%   zh:       基于 ctexart 类（继承所有中文默认排版设置，类选项会传递给 ctexart）
%   zh-plain: 基于 article 类并通过 \usepackage[scheme=plain]{ctex} 加载（提供基础的中文支持，但保留英文文档的排版习惯）
%   en:       仅基于 article 类（默认选项，不加载 ctex 宏包，所有 CJK 字体辅助命令将失效，以保证纯英文环境下编译不报错）
% 用法示例：
%   \documentclass{homework}                    % 默认英文环境（不加载 ctex）
%   \documentclass[lang=zh]{homework}           % 纯中文环境（基于 ctexart）
%   \documentclass[lang=zh-plain]{homework}     % 中英混排环境（基础版中文支持）
%   \documentclass[lang=en]{homework}           % 显式指定英文环境
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{homework}[2026/03/13 Homework Assignment Class]

% -------------------------------------------------------------
% 类选项处理 (Option handling)
% -------------------------------------------------------------
\newif\ifhwk@lang@zh
\newif\ifhwk@lang@zhplain
% 默认状态下为英文环境（两个布尔标记均为 false）

% 捕获预设的 lang 选项
\DeclareOption{lang=zh}{\hwk@lang@zhtrue}
\DeclareOption{lang=zh-plain}{\hwk@lang@zhplaintrue}
\DeclareOption{lang=en}{% 显式指定英文 -> 不修改布尔状态
}
% 处理一般形式的类选项
\DeclareOption*{%
  \begingroup
    \edef\temp@opt{\CurrentOption}
    \expandafter\ifx\temp@opt\@empty\else
      % 尝试手动解析 lang= 前缀选项（已知值已在上方处理，此处可预留未来扩展）
    \fi
  \endgroup
  % 将未知的类选项透传给 article 基类（如果后续加载的是 ctexart，不支持的选项会被自动忽略并产生警告）
  \PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax

% -------------------------------------------------------------
% 根据语言选项加载底层的文档类
% -------------------------------------------------------------
\ifhwk@lang@zh
  % 完整中文支持环境：使用 ctexart 作为基类，使其能正确接收并应用 \documentclass 的类选项（如字号等）
  \LoadClassWithOptions{ctexart}
  \newcommand*\hwk@ctexloaded{1}
  % 确保章节（例如 Problem N）的标题像 article 类一样左对齐，而不是默认居中
  \AtBeginDocument{\ctexset{section/format += \raggedright}}
\else\ifhwk@lang@zhplain
  % 基础中文支持环境：使用 article 作为基类，并额外引入 ctex 宏包（使用 plain 方案以保持英文排版）
  \LoadClass{article}
  \RequirePackage[scheme=plain]{ctex}
  \newcommand*\hwk@ctexloaded{1}
\else
  % 纯英文环境
  \LoadClass{article}
  \newcommand*\hwk@ctexloaded{0}
\fi\fi

% 编译引擎与字体支持（现代 LaTeX 强烈建议使用 XeLaTeX 或 LuaLaTeX 以支持 fontspec 及中文环境）
\RequirePackage{ifxetex}
\RequirePackage{ifluatex}
\ifnum 0\ifxetex 1\fi\ifluatex 1\fi=0
  \ClassError{homework}{The homework class requires XeLaTeX or LuaLaTeX}{Compile this document with XeLaTeX (recommended) or LuaLaTeX.}
\fi
\RequirePackage{fontspec}

% 引入数学与算法宏包
\RequirePackage{amsmath}
\RequirePackage{amsthm}
\RequirePackage{amsfonts}
\RequirePackage{tikz}
\usetikzlibrary{automata,positioning}
\RequirePackage[plain]{algorithm}
\RequirePackage{algpseudocode}

% 引入页眉页脚与章节格式设定宏包
\RequirePackage{fancyhdr}
\RequirePackage{extramarks}
\RequirePackage{titlesec}
\PassOptionsToPackage{pass}{geometry}
\RequirePackage{geometry}
\RequirePackage{etoolbox}

% 默认页面布局设置（尽可能兼容原版英文模板的边距参数）
\setlength{\topmargin}{-0.45in}
\setlength{\evensidemargin}{0in}
\setlength{\oddsidemargin}{0in}
\setlength{\textwidth}{6.5in}
\setlength{\textheight}{9.0in}
\setlength{\headsep}{0.25in}
\setlength{\headheight}{14pt}
\linespread{1.1}\selectfont
\setlength{\parindent}{0pt}

% 布局调整辅助命令（可选项，默认禁用）
% 用户可以在文档的导言区解除注释，并自行定义对应命令所需的间距参数
\newcommand{\homeworksetlinespread}[1]{\linespread{#1}\selectfont}
\newcommand{\homeworksetmargins}[1]{\geometry{#1}}
\newcommand{\homeworksetproblemtitlespacing}[2]{\titlespacing*{\section}{0pt}{#1}{#2}}

% 用于控制 \solution (解答) 标题及其上下文的间距
\newlength{\hmwkSolutionBeforeSkip}
\newlength{\hmwkSolutionAfterSkip}
\setlength{\hmwkSolutionBeforeSkip}{0.5\baselineskip}
\setlength{\hmwkSolutionAfterSkip}{0.5\baselineskip}
\newcommand{\homeworksetsolutionskip}[2]{%
  \setlength{\hmwkSolutionBeforeSkip}{#1}%
  \setlength{\hmwkSolutionAfterSkip}{#2}%
}
\newcommand{\solution}{%
  \par\vspace{\hmwkSolutionBeforeSkip}%
  \textbf{\large Solution}%
  \par\vspace{\hmwkSolutionAfterSkip}%
}

% 字体自定义辅助命令 (可选的)
% 如果是纯英文模式 (未加载 ctex)，为了防止引发 Undefined control sequence 错误，
% 我们提供空操作的包裹命令，但只在首次调用时抛出宏包警告提示用户命令不起作用。
\makeatletter
\ifx\hwk@ctexloaded\@undefined\def\hwk@ctexloaded{0}\fi
\newcommand\hwk@maybe@warn[1]{\ifnum\hwk@ctexloaded=0 \ClassWarning{homework}{CJK font command '#1' used but ctex not loaded (lang=en). No effect}\fi}
\ifnum\hwk@ctexloaded=1
  \newcommand{\homeworksetCJKmainfont}[2][]{\setCJKmainfont[#1]{#2}}
  \newcommand{\homeworksetCJKsansfont}[2][]{\setCJKsansfont[#1]{#2}}
  \newcommand{\homeworksetCJKmonofont}[2][]{\setCJKmonofont[#1]{#2}}
\else
  \newcommand{\homeworksetCJKmainfont}[2][]{\hwk@maybe@warn{homeworksetCJKmainfont}}
  \newcommand{\homeworksetCJKsansfont}[2][]{\hwk@maybe@warn{homeworksetCJKsansfont}}
  \newcommand{\homeworksetCJKmonofont}[2][]{\hwk@maybe@warn{homeworksetCJKmonofont}}
\fi
\makeatother
\newcommand{\homeworksetmainfont}[2][]{\setmainfont[#1]{#2}}
\newcommand{\homeworksetsansfont}[2][]{\setsansfont[#1]{#2}}
\newcommand{\homeworksetmonofont}[2][]{\setmonofont[#1]{#2}}
\makeatletter
\newcommand{\homeworksetmathfont}[2][]{%
  \@ifpackageloaded{unicode-math}{%
    \setmathfont[#1]{#2}%
  }{%
    \RequirePackage{unicode-math}%
    \setmathfont[#1]{#2}%
  }%
}
\makeatother

% fancyhdr 页眉页脚排版配置
\pagestyle{fancy}
\fancyhf{}
\lhead{\hmwkAuthorName}
\chead{\hmwkClass\ (\hmwkClassInstructor\ \hmwkClassTime): \hmwkTitle}
\rhead{\firstxmark}
\lfoot{\lastxmark}
\cfoot{\thepage}
\renewcommand\headrulewidth{0.4pt}
\renewcommand\footrulewidth{0.4pt}

% 作业题目区块环境 (Problem section) 及翻页标记(Extramarks)处理辅助命令
\newcommand{\enterProblemHeader}[1]{%
  \nobreak\extramarks{}{Problem \arabic{#1} continued on next page\ldots}\nobreak{}
  \nobreak\extramarks{Problem \arabic{#1} (continued)}{Problem \arabic{#1} continued on next page\ldots}\nobreak{}
}
\newcommand{\exitProblemHeader}[1]{%
  \nobreak\extramarks{Problem \arabic{#1} (continued)}{Problem \arabic{#1} continued on next page\ldots}\nobreak{}
  \stepcounter{#1}%
  \nobreak\extramarks{Problem \arabic{#1}}{}\nobreak{}
}

\setcounter{secnumdepth}{0}
\newcounter{partCounter}
\newcounter{homeworkProblemCounter}
\setcounter{homeworkProblemCounter}{1}
\nobreak\extramarks{Problem \arabic{homeworkProblemCounter}}{}\nobreak{}

\newenvironment{homeworkProblem}[1][-1]{%
  \ifnum#1>0
    \setcounter{homeworkProblemCounter}{#1}%
  \fi
  \section{Problem \arabic{homeworkProblemCounter}}
  \setcounter{partCounter}{1}%
  \enterProblemHeader{homeworkProblemCounter}%
}{%
  \exitProblemHeader{homeworkProblemCounter}%
}

% 文档元数据（预设了一些带默认值的宏，用户需在文档导言区重定义其内容以匹配自身信息）
\newcommand{\hmwkTitle}{Homework}
\newcommand{\hmwkDueDate}{}
\newcommand{\hmwkClass}{Course Name}
\newcommand{\hmwkClassTime}{Class Time}
\newcommand{\hmwkClassInstructor}{Instructor}
\newcommand{\hmwkAuthorName}{Author}

\renewcommand{\part}[1]{\textbf{\large Part \Alph{partCounter}}\stepcounter{partCounter}\\}

% 封面标题页 (Title page) 排版配置
\title{%
  \vspace{2in}%
  \textmd{\textbf{\hmwkClass:\ \hmwkTitle}}\\
  \vspace{0.1in}\large{\textit{\hmwkClassInstructor\ \hmwkClassTime}}\\
  \normalsize\vspace{0.1in}\small{Due\ Date:\ \hmwkDueDate}%
  \vspace{3in}%
}
\author{\hmwkAuthorName}
\date{\today}

\makeatletter
\let\hmwk@oldmaketitle\maketitle
\renewcommand{\maketitle}{%
  \hmwk@oldmaketitle
  \thispagestyle{empty}% 去掉标题页页码/页脚
  \setcounter{page}{0}% 让下一页成为第 1 页
}
\makeatother

% 常用数学符号及其它辅助宏命令
\newcommand{\alg}[1]{\textsc{\bfseries \footnotesize #1}}
\newcommand{\deriv}[1]{\frac{\mathrm{d}}{\mathrm{d}x} (#1)}
\newcommand{\pderiv}[2]{\frac{\partial}{\partial #1} (#2)}
\newcommand{\dx}{\mathrm{d}x}
\newcommand{\E}{\mathrm{E}}
\newcommand{\Var}{\mathrm{Var}}
\newcommand{\Cov}{\mathrm{Cov}}
\newcommand{\Bias}{\mathrm{Bias}}

