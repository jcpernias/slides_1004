%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{exam}[2018/10/10 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{Spanish}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{English}{\booltrue{langEN}\boolfalse{langES}}

\DeclareOption*{%
  \ClassError{exam}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `exam' class}}
\ExecuteOptions{Spanish}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\LoadClass[a4paper, 12pt]{article}


%% Load packages
%% --------------------------------------------------------------------------------
\RequirePackage{docs-base}
\RequirePackage{docs-pages}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-rules}
\RequirePackage{docs-lists}
\RequirePackage{docs-units}
\RequirePackage{docs-marks}
\RequirePackage{docs-tables}
\RequirePackage{docs-hyper}

%% Title
%% --------------------------------------------------------------------------------

% \usepackage{titling}

% \pretitle{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
% \posttitle{\par\end{flushleft}}

% \preauthor{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
% \postauthor{\par\end{flushleft}}

% \predate{\begin{flushleft}\Large\sffamily\bfseries\color{Title}}
% \postdate{\par\end{flushleft}}


%% Cover
%% ================================================================================


% \RequirePackage{rerunfilecheck}
% \RequirePackage{newfile}

% \RequirePackage{translator}
% \usedictionary{docs-exam}

% \newoutputstream{instructions}
% \newcommand*{\outfile}{\jobname.instructions}
% \newcommand{\safeinput}[1]{%
%   \IfFileExists{#1}{\bgroup\input{#1}\egroup}{}}

% \newenvironment{instructions}{%
%   \RerunFileCheck{\outfile}{\closeoutputstream{instructions}}{%
%     Rerun LaTeX to get instructions right
%   }%
%   \openoutputfile{\outfile}{instructions}%
%   \writeverbatim{instructions}%
  % \bgroup%
  % \normalfont\vspace*{2em}\large%
  % \noindent\textbf{\translate{General Instructions}:}\\%
  % \egroup
%   }{%
%   \endwriteverbatim}

% \newcommand{\printinstructions}{\safeinput{\outfile}}


% \newoutputstream{header}
% \newcommand*{\headerfile}{\jobname.header}

% \newenvironment{header}{%
%   \RerunFileCheck{\headerfile}{\closeoutputstream{header}}{%
%     Rerun LaTeX to get header right
%   }%
%   \openoutputfile{\headerfile}{header}%
%   \writeverbatim{header}%
%   \bgroup\egroup% If not included, \normalfont is not written
%   \normalfont\vspace*{2em}\large%
%   \raggedright%
% }{\endwriteverbatim}

% \newcommand{\printheader}{\safeinput{\headerfile}}

\AtBeginDocument{%
  \color{MainText}%
  % \pagenumbering{roman}%
  % \pagestyle{empty}%
  % \maketitle%
  \thispagestyle{empty}%
  % \printheader%
  % \printinstructions%
  % \cleardoublepage{}
  % \pagenumbering{arabic}
  % \pagestyle{plain}
}



