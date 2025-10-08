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
% Option handling
% -------------------------------------------------------------
\newif\ifhwk@lang@zh
\newif\ifhwk@lang@zhplain
% default English (both flags false)

% capture lang option
\DeclareOption{lang=zh}{\hwk@lang@zhtrue}
\DeclareOption{lang=zh-plain}{\hwk@lang@zhplaintrue}
\DeclareOption{lang=en}{% explicit English -> no flags
}
% generic key form lang=<value>
\DeclareOption*{%
  \begingroup
    \edef\temp@opt{\CurrentOption}
    \expandafter\ifx\temp@opt\@empty\else
      % try to parse lang= prefix manually (already handled above for known values)
    \fi
  \endgroup
  % pass unknown options to the base class (article/ctexart)
  \PassOptionsToClass{\CurrentOption}{article}% will be ignored by ctexart if unsupported
}
\ProcessOptions\relax

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
\RequirePackage{tikz}
\usetikzlibrary{automata,positioning}
\RequirePackage[plain]{algorithm}
\RequirePackage{algpseudocode}

% Header/footer and section formatting
\RequirePackage{fancyhdr}
\RequirePackage{extramarks}
\RequirePackage{titlesec}
\PassOptionsToPackage{pass}{geometry}
\RequirePackage{geometry}
\RequirePackage{etoolbox}

% Default layout closely follows the original template
\setlength{\topmargin}{-0.45in}
\setlength{\evensidemargin}{0in}
\setlength{\oddsidemargin}{0in}
\setlength{\textwidth}{6.5in}
\setlength{\textheight}{9.0in}
\setlength{\headsep}{0.25in}
\setlength{\headheight}{14pt}
\linespread{1.1}\selectfont
\setlength{\parindent}{0pt}

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
  \textbf{\large Solution}%
  \par\vspace{\hmwkSolutionAfterSkip}%
}

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

% Helper macros
\newcommand{\alg}[1]{\textsc{\bfseries \footnotesize #1}}
\newcommand{\deriv}[1]{\frac{\mathrm{d}}{\mathrm{d}x} (#1)}
\newcommand{\pderiv}[2]{\frac{\partial}{\partial #1} (#2)}
\newcommand{\dx}{\mathrm{d}x}
\newcommand{\E}{\mathrm{E}}
\newcommand{\Var}{\mathrm{Var}}
\newcommand{\Cov}{\mathrm{Cov}}
\newcommand{\Bias}{\mathrm{Bias}}

