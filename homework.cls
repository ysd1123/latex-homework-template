% Homework assignment class based on the original template
% Provides optional Chinese (ctex) support and configurable layout hooks
% Added option: lang = zh | zh-plain | en (default)
%   zh:       base on ctexart (inherits all Chinese defaults, class options pass to ctexart)
%   zh-plain: base on article + \usepackage[scheme=plain]{ctex} (minimal Chinese support, similar to previous version)
%   en:       base on article only (no ctex loaded, CJK helpers become no-ops)
% Usage examples:
%   \documentclass{homework}                    % English (no ctex)
%   \documentclass[lang=zh]{homework}           % Chinese full defaults (ctexart)
%   \documentclass[lang=zh-plain]{homework}     % Chinese minimal (article + ctex[scheme=plain])
%   \documentclass[lang=en]{homework}           % Explicit English
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{homework}[2024/05/08 Homework assignment class]

% -------------------------------------------------------------
% 选项解析模块：集中定义类选项，便于统一扩展
% -------------------------------------------------------------
\newif\ifhwk@lang@zh       % lang=zh 时为真
\newif\ifhwk@lang@zhplain  % lang=zh-plain 时为真

% 使用 kvoptions 提供的键值选项解析框架，便于后续扩展
\RequirePackage{kvoptions}
\RequirePackage{etoolbox}

% 统一设置选项前缀：hwk@<option>
\SetupKeyvalOptions{family=hwk,prefix=hwk@}

% 字符串选项（默认值采用 "auto"，后续按语言再决定实际内容）
\DeclareStringOption[en]{lang}
\DeclareStringOption[auto]{problemname}
\DeclareStringOption[auto]{solutionname}
\DeclareStringOption[auto]{proofname}
\DeclareStringOption[plain]{problemstyle}
\DeclareStringOption[light]{theme}
\DeclareStringOption[plain]{captionstyle}
\DeclareStringOption[auto]{linespread}
\DeclareStringOption[auto]{indent}
\DeclareStringOption[auto]{duedatelabel}
\DeclareStringOption[auto]{problemcolor}
\DeclareStringOption[auto]{problemframe}
\DeclareStringOption[auto]{subproblemcolor}
\DeclareStringOption[auto]{subproblemframe}

% 布尔选项（缺省均为 false）
\DeclareBoolOption{subnumbering}
\DeclareBoolOption{tightlists}
\DeclareBoolOption{mathdelims}
\DeclareBoolOption{statmacros}
\DeclareBoolOption{chinesenumbering}
\DeclareBoolOption{localizedate}
\DeclareBoolOption{minimal}
\DeclareBoolOption{fastcompile}

% 未识别的选项继续透传给基础类（article / ctexart）
\DeclareDefaultOption{%
  \PassOptionsToClass{\CurrentOption}{article}%
  \PassOptionsToClass{\CurrentOption}{ctexart}%
}

% 解析所有选项（包括 kvoptions 定义的键值选项）
\makeatletter
\ProcessKeyvalOptions*\relax

% -------------------------------------------------------------
% 选项后处理：依据 lang 设置内部状态与默认值
% -------------------------------------------------------------
\edef\hwk@lang@tmp{\hwk@lang}
\lowercase{\edef\hwk@lang@normalized{\hwk@lang@tmp}}
\hwk@lang@zhfalse
\hwk@lang@zhplainfalse
\def\hwk@tmpa{zh}
\def\hwk@tmpb{zh-plain}
\def\hwk@tmpc{en}
\ifx\hwk@lang@normalized\hwk@tmpa
  \hwk@lang@zhtrue
\else\ifx\hwk@lang@normalized\hwk@tmpb
  \hwk@lang@zhplaintrue
\else\ifx\hwk@lang@normalized\hwk@tmpc
  % lang=en，保持默认
\else
  \ClassWarning{homework}{Unknown lang option '\hwk@lang'. Fallback to 'en'.}
  \let\hwk@lang@normalized\hwk@tmpc
\fi\fi\fi

% 根据语言与 auto 选项决定题目/解答/证明等标签默认值
\def\hwk@auto{auto}
\ifx\hwk@problemname\hwk@auto
  \ifhwk@lang@zh \def\hwk@problemname{题目}\else\ifhwk@lang@zhplain \def\hwk@problemname{题目}\else \def\hwk@problemname{Problem}\fi\fi
\fi
\ifx\hwk@solutionname\hwk@auto
  \ifhwk@lang@zh \def\hwk@solutionname{解答}\else\ifhwk@lang@zhplain \def\hwk@solutionname{解答}\else \def\hwk@solutionname{Solution}\fi\fi
\fi
\ifx\hwk@proofname\hwk@auto
  \ifhwk@lang@zh \def\hwk@proofname{证明}\else\ifhwk@lang@zhplain \def\hwk@proofname{证明}\else \def\hwk@proofname{Proof}\fi\fi
\fi
% 暴露统一命名宏，后续排版中直接引用这些名称
\newcommand*{\hmwkProblemName}{\hwk@problemname}
\newcommand*{\hmwkSolutionName}{\hwk@solutionname}
\newcommand*{\hmwkProofName}{\hwk@proofname}

% 延迟到文档开始时更新 amsthm 的证明标题，避免加载顺序问题
\AtBeginDocument{\renewcommand{\proofname}{\hmwkProofName}}

% -------------------------------------------------------------
% 题面环境辅助变量与钩子
% -------------------------------------------------------------
\newif\ifhwk@problem@nostep           % 星号题目环境时禁止累加计数器
\hwk@problem@nostepfalse
\def\hwk@problem@customtitle{}        % 用户定制的题目标题（problem 环境可写）
\def\hmwk@currentProblemMarker{}      % 当前题目的页眉提示文本
\newcommand{\homeworkBeforeProblemHook}{} % 题目前钩子（可通过 \renewcommand 重定义）
\newcommand{\homeworkAfterProblemHook}{}  % 题目后钩子
\newcommand{\homeworksetproblemtitle}[1]{\def\hwk@problem@customtitle{#1}} % 兼容旧接口：手动指定下一题标题

% 盒式样式辅助宏（默认不做任何事，后续根据 problemstyle 选项重定义）
\newcommand{\hwk@beginProblemBox}{}
\newcommand{\hwk@endProblemBox}{}
\newcommand{\hwk@beginSubproblemBox}{}
\newcommand{\hwk@endSubproblemBox}{}

% ------- 中文编号与日期工具（chinesenumbering / localizedate） -------
\newif\ifhwkChnWarned
\hwkChnWarnedfalse
\newcommand{\hwkCounterToChinese}[1]{%
  \ifnum\hwk@ctexloaded=1
    \chinese{#1}%
  \else
    \ifhwkChnWarned\else
      \ClassWarning{homework}{选项 chinesenumbering 需要 lang=zh 或 lang=zh-plain；已退回为阿拉伯数字}%
      \hwkChnWarnedtrue
    \fi
    \arabic{#1}%
  \fi
}
\newcommand{\hwkTwodigits}[1]{\ifnum#1<10 0\fi\number#1}
\newcommand{\hwkFormatChineseDate}[3]{#1年#2月#3日}
\newcommand{\hwkFormatIsoDate}[3]{#1-#2-#3}

% 排版细节选项后处理（缩进、行距、标题名、最小化模式等）
\ifhwk@minimal
  % 最小化模式下关闭所有可选增强效果
  \def\hwk@problemstyle{plain}%
  \def\hwk@captionstyle{plain}%
  \hwk@tightlistsfalse
  \hwk@mathdelimsfalse
  \hwk@statmacrosfalse
  \hwk@chinesenumberingfalse
  \hwk@localizedatefalse
  \hwk@fastcompiletrue
\fi

% 计算最终样式关键词，方便后续比较
\edef\hwk@problemstylefinal{\hwk@problemstyle}
\edef\hwk@captionstylefinal{\hwk@captionstyle}
\def\hwk@tmp@captionplain{plain}
\def\hwk@tmp@captionchinese{chinese}
\def\hwk@tmp@captioncompact{compact}
\def\hwk@tmp@boxed{boxed}
\ifx\hwk@captionstylefinal\hwk@auto
  \ifhwk@lang@zh \def\hwk@captionstylefinal{chinese}%
  \else\ifhwk@lang@zhplain \def\hwk@captionstylefinal{chinese}%
  \else \def\hwk@captionstylefinal{plain}%
  \fi\fi
\fi
\ifhwk@minimal \def\hwk@captionstylefinal{plain}\fi

% 行距 linespread 解析
\edef\hwk@linespreadchoice{\hwk@linespread}
\def\hwk@linespreadresolved{1.1}
\def\hwk@tmp@tight{tight}
\def\hwk@tmp@normal{normal}
\def\hwk@tmp@comfort{comfort}
\def\hwk@tmp@loose{loose}
\ifx\hwk@linespreadchoice\hwk@auto
  \ifhwk@lang@zh \def\hwk@linespreadresolved{1.15}%
  \else\ifhwk@lang@zhplain \def\hwk@linespreadresolved{1.15}%
  \else \def\hwk@linespreadresolved{1.1}%
  \fi\fi
  \ifhwk@minimal \def\hwk@linespreadresolved{1.05}\fi
\else\ifx\hwk@linespreadchoice\hwk@tmp@tight
  \def\hwk@linespreadresolved{1.0}%
\else\ifx\hwk@linespreadchoice\hwk@tmp@normal
  \def\hwk@linespreadresolved{1.1}%
\else\ifx\hwk@linespreadchoice\hwk@tmp@comfort
  \def\hwk@linespreadresolved{1.2}%
\else\ifx\hwk@linespreadchoice\hwk@tmp@loose
  \def\hwk@linespreadresolved{1.3}%
\else
  \def\hwk@linespreadresolved{\hwk@linespreadchoice}% 用户自定义数值
\fi\fi\fi\fi\fi

% 段首缩进 indent 解析
\edef\hwk@indentchoice{\hwk@indent}
\def\hwk@indentresolved{0pt}
\def\hwk@tmp@none{none}
\ifx\hwk@indentchoice\hwk@auto
  \ifhwk@minimal
    \def\hwk@indentresolved{0pt}%
  \else
    \ifhwk@lang@zh \def\hwk@indentresolved{2em}%
    \else\ifhwk@lang@zhplain \def\hwk@indentresolved{2em}%
    \else \def\hwk@indentresolved{0pt}%
    \fi\fi
  \fi
\else\ifx\hwk@indentchoice\hwk@tmp@none
  \def\hwk@indentresolved{0pt}%
\else
  \def\hwk@indentresolved{\hwk@indentchoice}% 用户自定义尺寸
\fi\fi

% 日期标签：auto -> 中文“截止日期：”，英文保留 “Due Date:”
% 同时结合 localizedate 选项覆盖 \today 格式
\edef\hwk@duedatelabelchoice{\hwk@duedatelabel}
\def\hmwkDueDateLabel{Due\ Date:}% 默认英文标签
\ifx\hwk@duedatelabelchoice\hwk@auto
  \ifhwk@localizedate
    \def\hmwkDueDateLabel{截止日期：}%
  \else
    \ifhwk@lang@zh \def\hmwkDueDateLabel{截止日期：}%
    \else\ifhwk@lang@zhplain \def\hmwkDueDateLabel{截止日期：}%
    \fi\fi
  \fi
\else
  \def\hmwkDueDateLabel{\hwk@duedatelabelchoice}% 用户自定义标签
\fi

\ifhwk@localizedate
  \AtBeginDocument{%
    \ifhwk@lang@zh
      \renewcommand{\today}{\hwkFormatChineseDate{\number\year}{\hwkTwodigits{\month}}{\hwkTwodigits{\day}}}%
    \else\ifhwk@lang@zhplain
      \renewcommand{\today}{\hwkFormatChineseDate{\number\year}{\hwkTwodigits{\month}}{\hwkTwodigits{\day}}}%
    \else
      \renewcommand{\today}{\hwkFormatIsoDate{\number\year}{\hwkTwodigits{\month}}{\hwkTwodigits{\day}}}%
    \fi\fi
  }
\fi

% -------------------------------------------------------------
% 颜色主题与盒式样式配置（theme / problemstyle 组合）
% -------------------------------------------------------------
\edef\hwk@themechoice{\hwk@theme}
\def\hwk@themeLight{light}
\def\hwk@themeGray{gray}
\def\hwk@themeColor{color}
\def\hwk@problem@colback{blue!3}
\def\hwk@problem@colframe{blue!50!black!35}
\def\hwk@subproblem@colback{blue!8!white}
\def\hwk@subproblem@colframe{blue!55!black!30}
\ifx\hwk@themechoice\hwk@themeGray
  \def\hwk@problem@colback{gray!6}
  \def\hwk@problem@colframe{gray!70!black}
  \def\hwk@subproblem@colback{gray!9}
  \def\hwk@subproblem@colframe{gray!65!black}
\else\ifx\hwk@themechoice\hwk@themeColor
  \def\hwk@problem@colback{teal!8}
  \def\hwk@problem@colframe{teal!60!black!35}
  \def\hwk@subproblem@colback{orange!10}
  \def\hwk@subproblem@colframe{orange!65!black!35}
\fi\fi

% 用户自定义颜色优先
\ifx\hwk@problemcolor\hwk@auto\else
  \def\hwk@problem@colback{\hwk@problemcolor}
\fi
\ifx\hwk@problemframe\hwk@auto\else
  \def\hwk@problem@colframe{\hwk@problemframe}
\fi
\ifx\hwk@subproblemcolor\hwk@auto\else
  \def\hwk@subproblem@colback{\hwk@subproblemcolor}
\fi
\ifx\hwk@subproblemframe\hwk@auto\else
  \def\hwk@subproblem@colframe{\hwk@subproblemframe}
\fi

% 盒式样式：仅当 problemstyle=boxed 时启用 tcolorbox 配色方案
\ifx\hwk@problemstylefinal\hwk@tmp@boxed
  \RequirePackage{xcolor}
  \RequirePackage{tcolorbox}
  \tcbuselibrary{skins,breakable}
  \tcbset{colback=white}
  \ifhwk@fastcompile
    \tcbset{
      homework problem/.style={breakable,colback=\hwk@problem@colback,colframe=\hwk@problem@colframe,left=6pt,right=6pt,top=4pt,bottom=4pt,boxrule=0.5pt,arc=0pt,enhanced=false,before skip=6pt,after skip=10pt},
      homework subproblem/.style={breakable,colback=\hwk@subproblem@colback,colframe=\hwk@subproblem@colframe,left=5pt,right=5pt,top=3pt,bottom=3pt,boxrule=0.4pt,arc=0pt,enhanced=false,before skip=4pt,after skip=6pt}
    }
  \else
    \tcbset{
      homework problem/.style={enhanced,breakable,colback=\hwk@problem@colback,colframe=\hwk@problem@colframe,left=8pt,right=8pt,top=6pt,bottom=6pt,boxrule=0.8pt,arc=2pt,sharp corners=all,frame style={opacity=0.9},before skip=8pt,after skip=12pt},
      homework subproblem/.style={enhanced,breakable,colback=\hwk@subproblem@colback,colframe=\hwk@subproblem@colframe,left=6pt,right=6pt,top=4pt,bottom=4pt,boxrule=0.6pt,arc=1.5pt,frame style={opacity=0.9},before skip=4pt,after skip=6pt}
    }
  \fi
  \renewcommand{\hwk@beginProblemBox}{\begin{tcolorbox}[homework problem]}
  \renewcommand{\hwk@endProblemBox}{\end{tcolorbox}}
  \renewcommand{\hwk@beginSubproblemBox}{\begin{tcolorbox}[homework subproblem]}
  \renewcommand{\hwk@endSubproblemBox}{\end{tcolorbox}}
\else
  % 普通模式保持原样（无额外盒子包装）
  \renewcommand{\hwk@beginProblemBox}{}
  \renewcommand{\hwk@endProblemBox}{}
  \renewcommand{\hwk@beginSubproblemBox}{}
  \renewcommand{\hwk@endSubproblemBox}{}
\fi
% 行距与缩进：auto 表示沿用类默认，不在此阶段处理
% duedatelabel: auto -> 由语言确定（中文改为“截止日期：”），稍后统一处理

% -------------------------------------------------------------
% Base class loading depending on lang
% -------------------------------------------------------------
\ifhwk@lang@zh
  % Full Chinese: use ctexart as base so class options apply
  \LoadClassWithOptions{ctexart}
  \newcommand*\hwk@ctexloaded{1}
  % Ensure section (Problem N) headings are left aligned like article
  \AtBeginDocument{\ctexset{section/format += \raggedright}}
\else\ifhwk@lang@zhplain
  % Minimal Chinese: article + ctex package (plain scheme)
  \LoadClass{article}
  \RequirePackage[scheme=plain]{ctex}
  \newcommand*\hwk@ctexloaded{1}
\else
  % English only
  \LoadClass{article}
  \newcommand*\hwk@ctexloaded{0}
\fi\fi

% Encoding and font support (only check engine when Chinese or user may want fontspec)
\RequirePackage{ifxetex}
\RequirePackage{ifluatex}
\ifnum 0\ifxetex 1\fi\ifluatex 1\fi=0
  \ClassError{homework}{The homework class requires XeLaTeX or LuaLaTeX}{Compile this document with XeLaTeX (recommended) or LuaLaTeX.}
\fi
\RequirePackage{fontspec}

% Mathematics and algorithm packages
\RequirePackage{amsmath}
\RequirePackage{amsthm}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage{tikz}
\usetikzlibrary{automata,positioning}
\RequirePackage{xcolor}
\RequirePackage[plain]{algorithm}
\RequirePackage{algpseudocode}

% Header/footer and section formatting
\RequirePackage{fancyhdr}
\RequirePackage{extramarks}
\RequirePackage{titlesec}
\PassOptionsToPackage{pass}{geometry}
\RequirePackage{geometry}

% Default layout closely follows the original template
\setlength{\topmargin}{-0.45in}
\setlength{\evensidemargin}{0in}
\setlength{\oddsidemargin}{0in}
\setlength{\textwidth}{6.5in}
\setlength{\textheight}{9.0in}
\setlength{\headsep}{0.25in}
\setlength{\headheight}{14pt}
\linespread{\hwk@linespreadresolved}\selectfont
\newlength{\hwk@indentlength}
\setlength{\hwk@indentlength}{\hwk@indentresolved}
\setlength{\parindent}{\hwk@indentresolved}
\ifdim\hwk@indentlength>0pt
  \RequirePackage{indentfirst}
\fi

% Optional layout adjustment helpers (disabled by default)
% Users may uncomment the corresponding commands in their documents.
\newcommand{\homeworksetlinespread}[1]{\linespread{#1}\selectfont}
\newcommand{\homeworksetmargins}[1]{\geometry{#1}}
\newcommand{\homeworksetproblemtitlespacing}[2]{\titlespacing*{\section}{0pt}{#1}{#2}}

% Solution heading spacing controls
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
  \textbf{\large \hmwkSolutionName}%
  \par\vspace{\hmwkSolutionAfterSkip}%
}

% ------- 紧凑列表支持（tightlists 选项） -------
\ifhwk@tightlists
  \RequirePackage{enumitem}
  \setlist{itemsep=0.35\baselineskip,topsep=0.45\baselineskip,parsep=0pt,partopsep=0pt}
  \setlist[itemize]{leftmargin=*,labelsep=0.6em}
  \setlist[enumerate]{leftmargin=*,labelsep=0.6em}
  \setlist[description]{style=nextline,leftmargin=*,font=\normalfont\bfseries}
\fi

% ------- 图表标题格式（captionstyle 选项） -------
\ifx\hwk@captionstylefinal\hwk@tmp@captionplain
  % plain：保持默认 caption 样式
\else
  \RequirePackage{caption}
  \ifx\hwk@captionstylefinal\hwk@tmp@captionchinese
    \captionsetup{font=small,labelfont=bf,labelsep=space,singlelinecheck=false,skip=10pt}
    \ifhwk@lang@zh \captionsetup{labelsep=quad,justification=raggedright}\fi
    \ifhwk@lang@zhplain \captionsetup{labelsep=quad,justification=raggedright}\fi
  \else\ifx\hwk@captionstylefinal\hwk@tmp@captioncompact
    \captionsetup{font=small,labelfont=bf,labelsep=space,skip=6pt}
  \else
    \captionsetup{labelfont=bf}
  \fi\fi
\fi

% Font customization helpers (optional)
% If ctex not loaded (English mode), provide no-op wrappers but warn once when used.
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

% Fancyhdr configuration
\pagestyle{fancy}
\fancyhf{}
\lhead{\hmwkAuthorName}
\chead{\hmwkClass\ (\hmwkClassInstructor\ \hmwkClassTime): \hmwkTitle}
\rhead{\firstxmark}
\lfoot{\lastxmark}
\cfoot{\thepage}
\renewcommand\headrulewidth{0.4pt}
\renewcommand\footrulewidth{0.4pt}

% Problem section helpers
\newcommand{\enterProblemHeader}[1]{%
  \nobreak\extramarks{}{\hmwk@currentProblemMarker~continued on next page\ldots}\nobreak{}
  \nobreak\extramarks{\hmwk@currentProblemMarker~(continued)}{\hmwk@currentProblemMarker~continued on next page\ldots}\nobreak{}
}
\newcommand{\exitProblemHeader}[1]{%
  \nobreak\extramarks{\hmwk@currentProblemMarker~(continued)}{\hmwk@currentProblemMarker~continued on next page\ldots}\nobreak{}
  \ifhwk@problem@nostep
    % 星号题目：不推进计数器，沿用当前标题作为页眉提示
  \else
    \stepcounter{#1}%
    \def\hmwk@currentProblemMarker{\hmwkProblemName~\arabic{#1}}%
  \fi
  \nobreak\extramarks{\hmwk@currentProblemMarker}{}\nobreak{}
}

\setcounter{secnumdepth}{0}
\newcounter{partCounter}
\newcounter{homeworkProblemCounter}
\newcounter{homeworkSubProblemCounter}
\setcounter{homeworkProblemCounter}{1}
\ifhwk@chinesenumbering
  \def\hmwk@currentProblemMarker{\hmwkProblemName~\hwkCounterToChinese{homeworkProblemCounter}}
\else
  \def\hmwk@currentProblemMarker{\hmwkProblemName~\arabic{homeworkProblemCounter}}
\fi
\nobreak\extramarks{\hmwk@currentProblemMarker}{}\nobreak{}

\newenvironment{homeworkProblem}[1][-1]{%
  \ifnum#1>0
    \setcounter{homeworkProblemCounter}{#1}%
  \fi
  \ifstrempty{\hwk@problem@customtitle}{%
    \ifhwk@chinesenumbering
      \def\hwk@problem@title{\hmwkProblemName~\hwkCounterToChinese{homeworkProblemCounter}}%
    \else
      \def\hwk@problem@title{\hmwkProblemName~\arabic{homeworkProblemCounter}}%
    \fi
  }{%
    \def\hwk@problem@title{\hwk@problem@customtitle}%
  }%
  \def\hmwk@currentProblemMarker{\hwk@problem@title}%
  \section{\hwk@problem@title}%
  \def\hwk@problem@customtitle{}%
  \setcounter{partCounter}{1}%
  \setcounter{homeworkSubProblemCounter}{0}%
  \enterProblemHeader{homeworkProblemCounter}%
  \hwk@beginProblemBox
  \homeworkBeforeProblemHook
}{%
  \homeworkAfterProblemHook
  \hwk@endProblemBox
  \exitProblemHeader{homeworkProblemCounter}%
  \hwk@problem@nostepfalse
}

% -------------------------------------------------------------
% 用户友好的 problem/subproblem/note 环境封装
% - problem / problem*: 委托给内部 homeworkProblem 计数
% - subproblem / subproblem*: 支持数字或 Part 编号，并可切换中文序号
% - note: 提供题内注记样式
% -------------------------------------------------------------
\newenvironment{problem}[1][]{%
  \hwk@problem@nostepfalse
  \ifstrempty{#1}{}{\def\hwk@problem@customtitle{#1}}%
  \begin{homeworkProblem}%
}{%
  \end{homeworkProblem}%
}

\newenvironment{problem*}[1][]{%
  \hwk@problem@nosteptrue
  \ifstrempty{#1}{}{\def\hwk@problem@customtitle{#1}}%
  \begin{homeworkProblem}%
}{%
  \end{homeworkProblem}%
}

% 子题环境：支持数字式（1.1）或字母式（Part A），可通过可选参数覆写标题
\newenvironment{subproblem}[1][]{%
  \par
  \ifstrempty{#1}{%
    \stepcounter{homeworkSubProblemCounter}%
    \ifhwk@subnumbering
      \ifhwk@chinesenumbering
        \edef\hwk@subproblem@label{\hwkCounterToChinese{homeworkProblemCounter}.\hwkCounterToChinese{homeworkSubProblemCounter}}%
        \def\hwk@subproblem@punct{}\relax
      \else
        \def\hwk@subproblem@label{\arabic{homeworkProblemCounter}.\arabic{homeworkSubProblemCounter}}%
        \def\hwk@subproblem@punct{.}\relax
      \fi
    \else
      \ifhwk@chinesenumbering
        \edef\hwk@subproblem@label{第\hwkCounterToChinese{partCounter}小题}%
        \stepcounter{partCounter}%
        \def\hwk@subproblem@punct{}\relax
      \else
        \def\hwk@subproblem@label{Part~\Alph{partCounter}}%
        \stepcounter{partCounter}%
        \def\hwk@subproblem@punct{.}\relax
      \fi
    \fi
  }{%
    \def\hwk@subproblem@label{#1}%
    \def\hwk@subproblem@punct{}\relax
  }%
  \hwk@beginSubproblemBox
  \noindent\textbf{\large \hwk@subproblem@label\hwk@subproblem@punct}\quad
}{%
  \hwk@endSubproblemBox
  \par
}

\newenvironment{subproblem*}[1][]{%
  \par
  \ifstrempty{#1}{%
    \ifhwk@subnumbering
      \ifhwk@chinesenumbering
        \edef\hwk@subproblem@label{\hwkCounterToChinese{homeworkProblemCounter}.\hwkCounterToChinese{homeworkSubProblemCounter}}%
        \def\hwk@subproblem@punct{}\relax
      \else
        \def\hwk@subproblem@label{\arabic{homeworkProblemCounter}.\arabic{homeworkSubProblemCounter}}%
        \def\hwk@subproblem@punct{.}\relax
      \fi
    \else
      \ifhwk@chinesenumbering
        \edef\hwk@subproblem@label{第\hwkCounterToChinese{partCounter}小题}%
        \def\hwk@subproblem@punct{}\relax
      \else
        \def\hwk@subproblem@label{Part~\Alph{partCounter}}%
        \def\hwk@subproblem@punct{.}\relax
      \fi
    \fi
  }{%
    \def\hwk@subproblem@label{#1}%
    \def\hwk@subproblem@punct{}\relax
  }%
  \hwk@beginSubproblemBox
  \noindent\textbf{\large \hwk@subproblem@label\hwk@subproblem@punct}\quad
}{%
  \hwk@endSubproblemBox
  \par
}

\newenvironment{note}[1][\hmwk@currentProblemMarker~的注记]{%
  \par\noindent\textbf{#1}\quad
}{%
  \par
}

% Metadata defaults (users should redefine in their documents)
\newcommand{\hmwkTitle}{Homework}
\newcommand{\hmwkDueDate}{}
\newcommand{\hmwkClass}{Course Name}
\newcommand{\hmwkClassTime}{Class Time}
\newcommand{\hmwkClassInstructor}{Instructor}
\newcommand{\hmwkAuthorName}{Author}

\renewcommand{\part}[1]{\textbf{\large Part \Alph{partCounter}}\stepcounter{partCounter}\\}

% Title page configuration
\title{%
  \vspace{2in}%
  \textmd{\textbf{\hmwkClass:\ \hmwkTitle}}\\
  \vspace{0.1in}\large{\textit{\hmwkClassInstructor\ \hmwkClassTime}}\\
  \normalsize\vspace{0.1in}\small{\hmwkDueDateLabel\ \hmwkDueDate}%
  \vspace{3in}%
}
\author{\hmwkAuthorName}
\date{\today}

\let\hmwk@oldmaketitle\maketitle
\renewcommand{\maketitle}{%
  \hmwk@oldmaketitle
  \thispagestyle{empty}% 去掉标题页页码/页脚
  \setcounter{page}{0}% 让下一页成为第 1 页
}

% Helper macros
\newcommand{\alg}[1]{\textsc{\bfseries \footnotesize #1}}
\newcommand{\deriv}[1]{\frac{\mathrm{d}}{\mathrm{d}x} (#1)}
\newcommand{\pderiv}[2]{\frac{\partial}{\partial #1} (#2)}
\newcommand{\dx}{\mathrm{d}x}
\newcommand{\E}{\mathrm{E}}
\newcommand{\Var}{\mathrm{Var}}
\newcommand{\Cov}{\mathrm{Cov}}
\newcommand{\Bias}{\mathrm{Bias}}

% ------- mathdelims 选项：提供常用成对定界符命令 -------
% mathdelims=true 时加载 mathtools，并声明 |·|、‖·‖、⌈⌉ 等常用括号
\ifhwk@mathdelims
  \RequirePackage{mathtools}
  \DeclarePairedDelimiter{\abs}{\lvert}{\rvert}
  \DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
  \DeclarePairedDelimiter{\ceil}{\lceil}{\rceil}
  \DeclarePairedDelimiter{\floor}{\lfloor}{\rfloor}
  \DeclarePairedDelimiter{\set}{\lbrace}{\rbrace}
  \DeclarePairedDelimiterX{\inner}[2]{\langle}{\rangle}{#1,#2}
\fi

% ------- statmacros 选项：概率/统计常用符号宏 -------
% 在 mathdelims 基础上扩展 \mathbb{E}/\operatorname{Var} 等写法
\ifhwk@statmacros
  \RequirePackage{mathtools}
  \renewcommand{\E}{\mathbb{E}}
  \renewcommand{\Var}{\operatorname{Var}}
  \renewcommand{\Cov}{\operatorname{Cov}}
  \renewcommand{\Bias}{\operatorname{Bias}}
  \newcommand{\Prob}[1]{\mathbb{P}\left(#1\right)}
  \newcommand{\Expect}[1]{\mathbb{E}\left[#1\right]}
  \newcommand{\VarOf}[1]{\operatorname{Var}\left[#1\right]}
  \newcommand{\CovOf}[2]{\operatorname{Cov}\left[#1,#2\right]}
  \newcommand{\BiasOf}[1]{\operatorname{Bias}\left[#1\right]}
  \newcommand{\given}{\,\middle|\,}
  \newcommand{\indicator}[1]{\mathbf{1}_{\{#1\}}}
\fi

\makeatother

