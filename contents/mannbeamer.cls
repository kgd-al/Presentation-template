\def\filedate{2019/08/07}
\def\fileversion{v1.2}

%% ----------------------------------- %%
%           Class options               %
%% ----------------------------------- %%

\newif\ifdr@ft
\dr@ftfalse
\DeclareOption{draft}{
  \dr@fttrue
%   \PassOptionsToClass{draft}{beamer}
  \ClassWarningNoLine{mannbeamer}{Draft mode is on. Please do not use generated pdf in \space a presentation...}
}

\newif\ifautooverview
\autooverviewfalse
\DeclareOption{auto_overview}{
 \autooverviewtrue
}

\newif\ifautosection
\autosectionfalse
\DeclareOption{auto_sections}{
 \autosectiontrue
}

\newif\ifmonitorprogress
\monitorprogressfalse
\DeclareOption{monitor_progress}{
 \monitorprogresstrue
}

\newif\ifshowdurations
\showdurationsfalse
\DeclareOption{show_durations}{
 \showdurationstrue
}

\DeclareOption*{\PassOptionsToClass{beamer}{\CurrentOption}}

\ProcessOptions*\relax

%% ----------------------------------- %%
%            Class setup                %
%% ----------------------------------- %%

\ProvidesClass{mannbeamer}[\filedate\space Created by Kevin Godin-Dubois^^J\fileversion]
\LoadClass{beamer}

% \RequirePackage{lmodern}

% \setkeys{Gin}{draft=false}
\hypersetup{final}

\RequirePackage{tikz}
\usetikzlibrary{fadings,calc}

% For patch command, see \beamer@sectionintoc
\RequirePackage{etoolbox}

% Normally for mathematical symbols but, in this case, toc subsections
\RequirePackage{wasysym}

% For duration computation (extraction)
\RequirePackage{xstring}

% For auto pnotes
\RequirePackage{pdfpcnotes}

\newif\ifnotappendix
\notappendixtrue

%% ----------------------------------- %%
%        Presentation setup             %
%% ----------------------------------- %%


\usetheme{Frankfurt}
\usecolortheme{dove}
\usefonttheme{serif}

\ifdr@ft
  \overfullrule=1mm
\else
%   \hypersetup{pdfpagemode=FullScreen}
\fi

% Nice gradient navigation
\begin{tikzfadingfrompicture}[name=fade bottom]
  \shade[top color=transparent!0,
  bottom color=transparent!100] (0,0) rectangle (2,2);
\end{tikzfadingfrompicture}
\setbeamertemplate{headline}{
  \hbox{\tikz\fill[path fading=fade bottom, black!90!white] (0,0) rectangle (\paperwidth, .8cm);}
  \vskip-0.6cm
  \insertnavigation{\paperwidth}
  \vskip0.4cm
}{}

% Shaded plan color
\def\opacity{\pgfsetfillopacity{0.33}}
\setbeamertemplate{section in head/foot shaded}{\opacity\usebeamertemplate{section in head/foot}\pgfsetfillopacity{1}}
\setbeamertemplate{section in toc shaded}{\opacity\usebeamertemplate{section in toc}\pgfsetfillopacity{1}}

% No navigation symbols + page numbers
\def\extrainfo{}
\def\infoslidenumber{-1}
\beamertemplatenavigationsymbolsempty
\setbeamertemplate{footline}{%
 \usebeamerfont{footline}%
 \usebeamercolor[fg]{footline}%
 
 % If there are extra informations and draft mode is on
 \ifdr@ft
  \ifx\extrainfo\empty
  \else
   % Insert them on the left and clear ?
   \edef\currframe{\theframenumber}

   \pnote{Should last \extrainfo}
   
   \ifnum\infoslidenumber = \currframe
    \ifshowdurations % Display frame-wide
     \tikz[remember picture, overlay]
      \node [minimum width=\paperwidth, minimum height=\paperheight, fill=gray!50, fill opacity=.5, text opacity=1]
            at (current page.center) {
             \resizebox{.9\textwidth}{!}{
              \begin{tabular}{c}
               \currframe \\
               \extrainfo
              \end{tabular}
             }
            };
    
    \else % Display in footline
     \hspace{1em}\emph{\extrainfo}
    \fi
   \else
    \gdef\extrainfo{\relax}
   \fi
  \fi
 \fi
 \hfill
 \insertframenumber/\inserttotalframenumber
 \hspace{0.25cm}
 \vspace{0.25cm}
}

% \setbeamertemplate{background}{%
%  \ifdr@ft
%   \ifx\extrainfo\empty
%   \else
%    \tikz[remember picture, overlay]
%     \node [minimum width=\paperwidth, minimum height=\paperheight, fill=gray!50!transparent]
%           at (current page.center) {\resizebox{.9\textwidth}{!}{\extrainfo}};
%   \fi
%  \fi
% }


% Title font
\setbeamerfont{title}{family*={pcr}}
\setbeamerfont{frametitle}{parent=title}

% Table of contents
\setbeamertemplate{section in toc}[ball unnumbered]
\setbeamertemplate{subsection in toc}{\hspace{0.5cm}{\small$\RHD$~\inserttocsubsection}\\}

% Auto named frames
\addtobeamertemplate{frametitle}{
 \setbox0=\hbox{\insertframetitle\unskip}
 \ifdim\wd0=0pt\relax
  \setbox0=\hbox{\subsecname\unskip}
  \ifdim\wd0=0pt
   \gdef\insertframetitle{\insertsection}
  \else
   \gdef\insertframetitle{\insertsubsection}
  \fi
  \setbox0=\hbox{\insertframesubtitle\unskip}
  \ifdim\wd0=0pt
   \setbox0=\hbox{\subsubsecname\unskip}
   \ifdim\wd0=0pt
    \setbox0=\hbox{\insertsectioncomment\unskip}
    \ifdim\wd0=0pt\relax\else
	 \let\insertframesubtitle\insertsectioncomment
    \fi
   \else
    \let\insertframesubtitle\insertsubsubsection
   \fi
  \fi
 \fi
}{}
\makeatletter
  \CheckCommand*\beamer@checkframetitle{\@ifnextchar\bgroup\beamer@inlineframetitle{}}
  \renewcommand*\beamer@checkframetitle{\global\let\beamer@frametitle\relax\@ifnextchar\bgroup\beamer@inlineframetitle{}}
\makeatother

% Section subtitle. To be used in conjonction with auto_sections
\newif\ifsectionhascomment
\sectionhascommentfalse
\def\insertsectioncomment{\relax}
\newcommand{\sectioncomment}[1]{
 \def\insertsectioncomment{#1}
 \sectionhascommenttrue
}
\newcommand{\clearsectioncomment}{
 \def\insertsectioncomment{\relax}
 \sectionhascommentfalse
}

\newcommand{\insertoverviewframe}{
 \begingroup
  \setbeamertemplate{frametitle}{}
  \setbeamertemplate{footline}{}
  \begin{frame}[noframenumbering, ok]
   \frametitle{Overview}
   \vfill
   \tableofcontents[
    sectionstyle=show/shaded,
    subsectionstyle=show/show/hide,
    subsubsectionstyle=hide/hide/hide/hide
   ]
   \vfill
  \end{frame}
 \endgroup
}

\newcommand{\insertsectionframe}{
\begingroup
 \setbeamertemplate{footline}{}
 \setbeamertemplate{frametitle}{}
 \begin{frame}[noframenumbering, ok]
  \begin{center}
   \vfill
   \usebeamerfont{title}\huge\insertsection \\
   \ifsectionhascomment
    \vspace{0.25cm}
    \usebeamerfont{subtitle} \insertsectioncomment
    \sectionhascommentfalse
   \fi
   \vfill
  \end{center}
 \end{frame}
\endgroup
}
   
% Auto generated intermission slides
% Either full section table of contents or simply its title (and subtitle if any)
\AtBeginSection[]{
 \xdef\subsecname{}
 \clearsectioncomment
 
 % Auto overview slides
 \ifautooverview
%   \makeatletter
%   \patchcmd{\beamer@sectionintoc}{\vskip1.5em}{\vfill}{}{}
%   \makeatother
    \insertoverviewframe
  \fi
  
 % Auto section names
 \ifautosection
  \insertsectionframe
 \fi  
}

\AtBeginSubsection[]{\clearsectioncomment}

\setbeamertemplate{note page}[plain]

%% ----------------------------------- %%
%            Notes slide                %
%% ----------------------------------- %%

\makeatletter
\ifdr@ft
 \newenvironment{notes}{
  \tikzset{%
    default/.style={draw, inner sep=0pt, minimum size=.1cm},%
    ok/.style={fill=green},%
    maybe/.style={fill=orange},
  }%
  \renewcommand{\note}[2][]{\tikz\node[default,##1]{};\hspace{.05cm}\tiny##2\\}%
  \begin{frame}[plain,noframenumbering,allowframebreaks,ok]%
   \frametitle{Notes}%
 }{
  \end{frame}
 }
\else
 \newenvironment{notes}{
  \renewcommand{\note}[2][]{}
 }{}
\fi
\makeatother

%% ----------------------------------- %%
%            Title slide                %
%% ----------------------------------- %%

\newcommand\formation[1]{
  \gdef\insertformation{#1}
}
\newcommand\titleheader[1]{
  \gdef\inserttitleheader{#1}
}
\newcommand\advisors[1]{
  \gdef\insertadvisors{#1}
}
\newcommand\dotitlepage{
 \frame[plain,noframenumbering]{\pnote{Font size test}}
 \frame[noframenumbering, plain, duration=30 s, ok]{
  \ifdefined\inserttitleheader
   \vspace{-1cm}
   \inserttitleheader
   \vspace{0.5cm}
  \fi
  \begin{center}
   \usebeamerfont{title} \textbf{\inserttitle} \\
   \if\relax\insertsubtitle\relax\else
    \usebeamerfont{subtitle} \insertsubtitle \\
   \fi
   \vspace{1cm}
   { \small \usebeamerfont{author} \insertauthor }\\
   \ifdefined\insertformation
    { \scriptsize \insertformation } \\
   \fi
   \vfill
   {
    \scriptsize \usebeamerfont{date} \insertdate 
    \par
   }
   \vspace{1cm}
   \ifdefined\insertadvisors
   {
    \scriptsize
    \insertadvisors
   }
   \fi
  \end{center}
 }
}


%% ----------------------------------- %%
%   Durations processing and display    %
%% ----------------------------------- %%

% Adds current duration option to the global value
\makeatletter
\def\processduration#1 #2 #3\relax{
 \edef\@tmp@total@duration{\totalduration}
 \if\relax\detokenize{#2}\relax
  \ClassWarningNoLine{mannbeamer}{Ignored malformed frame option 'duration=#1' at line \the\inputlineno.^^J}
  \ClassWarningNoLine{mannbeamer}{Format is: <number> <unit>^^J}
   
 \else
  \IfSubStr{#2}{min}{
   \edef\@tmp@frame@duration{\the\numexpr #1 * 60 \relax}
  }{
   \edef\@tmp@frame@duration{#1}
  }
  \IfStrEq{#3}{}{}{
   \edef\@tmp@frame@duration{\the\numexpr \@tmp@frame@duration + #3 \relax}
  }
  \xdef\totalduration{\the\numexpr \@tmp@total@duration + \@tmp@frame@duration \relax}

  % Formatting total duration
  \xdef\totalminutes{\the\numexpr \totalduration / 60 \relax}

  % Correct rounding issue
  \ifnum \totalduration < \the\numexpr \totalminutes * 60 \relax
   \edef\@tmp@total@minutes{\totalminutes}
   \edef\totalminutes{\the\numexpr \@tmp@total@minutes - 1 \relax}
  \fi
    
  \xdef\totalseconds{\the\numexpr \totalduration - (\totalminutes * 60) \relax}
  
 \fi
}

% Processes duration argument
\gdef\totalduration{0}
\define@key{beamerframe}{duration}{%
 \edef\infoslidenumber{\the\numexpr \theframenumber + 1 \relax}
 \ifnotappendix
   \def\extrainfo{#1 (\totalminutes'' \totalseconds')}
   \processduration#1 \relax
   \message{Processed duration^^J}
 \else
   \def\extrainfo{#1}
 \fi
}

% Displays the total duration in a user-friendly manner on the output
\AtEndDocument{
  \edef\totalminutes{\the\numexpr \totalduration / 60 \relax}

  % Correct rounding issue
  \ifnum \totalduration < \the\numexpr \totalminutes * 60 \relax
    \edef\@tmp@total@minutes{\totalminutes}
    \edef\totalminutes{\the\numexpr \@tmp@total@minutes - 1 \relax}
  \fi
  
  \edef\totalseconds{\the\numexpr \totalduration - (\totalminutes * 60) \relax}
  \message{Total duration = \totalduration \space = \totalminutes \space minutes \totalseconds \space seconds}
  
  \ifnum \totalduration = \the\numexpr \insertduration * 60 \relax\else
    \ClassWarningNoLine{mannbeamer}
                       {Total duration = \totalduration\space = \totalminutes\space minutes \totalseconds\space seconds}
    \ClassWarningNoLine{mannbeamer}{Expected \insertduration \space minutes}
  \fi
}
\makeatother


%% ----------------------------------- %%
%            Progress monitor           %
%% ----------------------------------- %%

% Note:
%   Not good enough in the long run. But should do the job for now
%  - Colors are not restored

\makeatletter

\definecolor{mannbeamer@nok@background}{hsb}{0,.1,1}
\definecolor{mannbeamer@nok@foreground}{hsb}{0,.2,1}

\definecolor{mannbeamer@hok@background}{hsb}{.1,.2,1}
\definecolor{mannbeamer@hok@foreground}{hsb}{.1,.4,1}

\BeforeBeginEnvironment{frame}{
 \ifmonitorprogress
  \setbeamercolor{background canvas}{bg=mannbeamer@nok@background}
  \setbeamercolor{frametitle}{bg=mannbeamer@nok@foreground}
 \fi
}
\define@key{beamerframe}{hok}[]{
 \ifmonitorprogress
  \setbeamercolor{background canvas}{bg=mannbeamer@hok@background}
  \setbeamercolor{frametitle}{bg=mannbeamer@hok@background}
 \fi
}
\define@key{beamerframe}{ok}[]{
 \ifmonitorprogress
  \setbeamercolor{background canvas}{bg=white}
  \setbeamercolor{frametitle}{bg=white}
 \fi
}
\makeatother


%% ----------------------------------- %%
%            Notes slide                %
%% ----------------------------------- %%

\makeatletter
\let\beamer@writeslidentry@excludefromnavoff=\beamer@writeslidentry%
\def\beamer@writeslidentry@excludefromnavon{%
  \expandafter\beamer@ifempty\expandafter{\beamer@framestartpage}{}% does not happen normally
  {%else
    % removed \addtocontents commands
    \clearpage\beamer@notesactions%
  }
}
\newcommand*{\excludefromnavon}{\let\beamer@writeslidentry=\beamer@writeslidentry@excludefromnavon}
\newcommand*{\excludefromnavoff}{\let\beamer@writeslidentry=\beamer@writeslidentry@excludefromnavoff}
\makeatother

%% ----------------------------------- %%
%       Final slides and appendix       %
%% ----------------------------------- %%

% -----------------------------------------------
% -- End pages numbering ------------------------

% Code is a tweaked version of the appendixnumberbeamer.sty package
% By default pages in the appendix are in the form (i+n / n) with n the last main matter slide

\makeatletter

\gdef\appendixtotalframenumber{0}
\def\mainend{-1}
\def\appendixname{Appendix}
\let\appendixorig\appendix

\def\appendix{
 % Inform pdfpc that the last frame has been reached
 \plastslide
 
 % Freeze numbering for main part
 \xdef\mainend{\theframenumber}
 \immediate\write\@auxout{\string\global\string\@namedef{mainendframenumber}{\mainend}}
 
 % Delegate appendix actions
 \appendixorig
 
 \headcommand{\gdef\inserttotalframenumber{\appendixtotalframenumber}}%
 \setcounter{framenumber}{0}
}

% To be called at the end of document to fix the total framenumber in the
% main document and in the appendix.
\def\pageatend{
 \xdef\appendixend{\theframenumber}
 \ifnum\mainend>0%
  \immediate\write\@auxout{\string\global\string\@namedef{appendixtotalframenumber}{\appendixend}}%
  \immediate\write\@auxout{\string\global\string\@namedef{inserttotalframenumber}{\mainend}}%
  \immediate\write\@auxout{\string\@writefile{nav}{\noexpand \headcommand {%
        \noexpand \gdef\noexpand \inserttotalframenumber{\mainend}}}}%
  \immediate\write\@auxout{\string\@writefile{nav}{\noexpand \headcommand {%
        \noexpand \gdef\noexpand \appendixtotalframenumber{\appendixend}}}}%
 \else
 \fi
}
\AtEndDocument{\pageatend}
\makeatother

% -----------------------------------------------
% -- End slides generation ----------------------

% Performs the following tasks :
%	- creates the thank you / questions slide
%	- creates the bibliography (if needed)
%	- switches to appendix mode (deactivates accumulation of frames duration + tweak page numerotation)
\newcounter{citations}
\setcounter{citations}{0}
\def\oldcite{} \let\oldcite=\cite
\def\cite{\stepcounter{citations}\oldcite}
\newcommand\doendpages[2][]{
 \autooverviewfalse
 \autosectionfalse

 \if\relax\detokenize{#2}\relax\else
  \excludefromnavon
  \subsection{}
  \begingroup
%    \setbeamertemplate{frametitle}{}
   \begin{frame}[plain,noframenumbering,label={lastslide}, #1]
    #2   
   \end{frame}
  \endgroup
  \excludefromnavoff
 \fi

 \appendix
 \global\notappendixfalse

 \begingroup
  \setbeamertemplate{footline}{}
    
  \excludefromnavon
  \begin{frame}[ok]{Annexes}
   \tableofcontents[
    sectionstyle=show/shaded,
    subsectionstyle=show/show/hide,
    subsubsectionstyle=hide/hide/hide/hide
   ]
  \end{frame}
  \excludefromnavoff
  
  \ifnum\thecitations>0
   \setbeamertemplate{frametitle continuation}{
    \ifnum\insertcontinuationcount>1
     (cont.)
    \fi
   }
   \setbeamertemplate{footline}{
    \ifnum\insertcontinuationcount>0
     \addtocounter{framenumber}{-1}
    \fi
   }
   \section{References}
   \begin{frame}[allowframebreaks, noframenumbering, ok]{References}
    \renewcommand{\section}[2]{}%
    \renewcommand*{\bibfont}{\tiny}
    \printbibliography
   \end{frame} 
  \fi
 \endgroup
}

%% ----------------------------------- %%
%              Tikz helpers             %
%% ----------------------------------- %%

\newenvironment{localto}[2][]{
 \path let \p1=(#2.center), \p2=(#2.north), \p3=(#2.east) in coordinate (#2X) at (\x3-\x1,0) coordinate (#2Y) at (0,\y2-\y1);
 \begin{scope}[x={(#2X)}, y={(#2Y)}, shift={(#2.center)},#1]
}{
 \end{scope}
}

%% ----------------------------------- %%
%                  Misc                 %
%% ----------------------------------- %%

\makeatletter
\def\finalgroup{%
\setkeys{Gin}{draft=false}%
\@latex@warning{graphicx draft mode locally deactivated}
}%
\makeatother

% End of mannbeamer class
