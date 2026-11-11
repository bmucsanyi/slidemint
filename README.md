# slidemint

`slidemint` is my Beamer theme for slide decks.

## Requirements

LuaLaTeX, `fontspec`, `unicode-math`, `biblatex` with `biber`, `minted` v3 with
the Catppuccin Pygments styles, `tikz`, and the font families Plus Jakarta Sans,
Roboto Condensed, and MesloLGS NF. minted runs `latexminted` from a Python
environment that is first on `PATH`:

```sh
uv venv
uv pip install latexminted "catppuccin[pygments]"
export PATH="$PWD/.venv/bin:$PATH"
```

## Installation

From the repository root:

```sh
l3build install
```

This installs the theme and `slidemintfonts.sty` into the user TeX tree, where
`kpsewhich beamerthemeslidemint.sty` finds them. For a deck that travels, vendor
the six files into its source.

## Usage

```tex
\documentclass[10pt,aspectratio=169,notheorems]{beamer}
\usetheme[palette = latte]{slidemint}
\usepackage{macromint}
\usepackage{figmint}
\addbibresource{references.bib}
\slidemintsetup{
  footer-left = {\textcopyright~Author, 2026},
}

\title{Talk title}
\author{Author}

\begin{document}
\maketitle

\begin{frame}
  \frametitle{Frame title}
  Content with a citation \citep{key}, and one in the footer.\citef{key}
\end{frame}

\begin{frame}[fragile]
  \frametitle{Code}
  \begin{minted}{python}
def loss(theta):
    return norm(theta)
  \end{minted}
\end{frame}

\begin{frame}[allowframebreaks]
  \frametitle{References}
  \printbibliography[heading=none]
\end{frame}
\end{document}
```

The palettes are `latte`, `frappe`, `macchiato`, `mocha`, and `minimalist`,
which is Latte on white with dark titles. The palette selects the Catppuccin
Pygments style of the code and the figmint theme of the figures, and figmint
draws the figures of a deck at a height to width ratio of 0.48.

Citations go through biblatex with biber, in author-year style with the natbib
commands `\citep` and `\citet`, and `\printbibliography` on a reference frame.
`\citef{key}` sets the cited entries in the footer of the frame instead, one
line each, in place of the footer text. `cite-highlight` names a family name to
set in bold there.

The fonts of a deck are in `slidemintfonts.sty`, which the theme loads and
which figmint loads to draw the figures in the deck's fonts. An article can load
it on its own.

## Public interface

- The option `palette`.
- `\slidemintsetup` with the keys `footer-left` and `cite-highlight`.
- `\citef{keys}`.
- `ribbon`, and `alignedblock`, `alignedalertblock`, and `alignedexampleblock`,
  which take the height of the body and the title:
  `\begin{alignedblock}{3cm}{Title}`.
- `\SlidemintTextbf`, `\SlidemintTextit`, and `\SlidemintEmph`, colored
  emphasis. `\textbf`, `\textit`, and `\emph` keep their meaning.
- `\SlidemintCodeFont`.
- `\ifSlidemintDarkMode`, true under `frappe`, `macchiato`, and `mocha`.
- The semantic colors: `SlidemintText`, `SlidemintSubtext`, `SlidemintMuted`,
  `SlidemintBase`, `SlidemintSurface`, `SlidemintPanel`, `SlidemintCrust`,
  `SlidemintSurfaceZero` to `SlidemintSurfaceTwo`, `SlidemintOverlayZero` to
  `SlidemintOverlayTwo`, `SlidemintAccent`, `SlidemintHeading`,
  `SlidemintListMarker`, `SlidemintStrong`, `SlidemintEmphasis`,
  `SlidemintStrongEmphasis`, `SlidemintLink`, `SlidemintExternalLink`,
  `SlidemintOnAccent`, `SlidemintAlert`, `SlidemintRule`,
  `SlidemintBlockTitle`, `SlidemintBlockBody`, `SlidemintAlertTitle`,
  `SlidemintAlertBody`, `SlidemintExampleTitle`, `SlidemintExampleBody`,
  `SlidemintCodeBody`, `SlidemintRibbonBody`, and the fourteen Catppuccin hues
  of the palette, `SlidemintRosewater` to `SlidemintLavender`.
- `slidemintfonts.sty`.

## Tests

From the repository root:

```sh
l3build check
```

The tests need checkouts of `figmint`, which provides the shared test harness,
and `macromint` next to this repository, the `.venv` above, the three font
families, `biber`, `pdftoppm`, and `pdftotext`.

## License

Apache 2.0.
