# slidemint

`slidemint` is a LuaLaTeX-only `beamer` theme for visual slide decks.

## Requirements

Compile decks with LuaLaTeX. Install the Plus Jakarta Sans, Roboto Condensed,
MesloLGS NF, and Latin Modern Math font families.

The theme uses `fontspec`, `unicode-math`, and `minted` v3. Code highlighting
uses the Catppuccin Pygments styles. Put a Python environment containing
`latexminted` and `catppuccin[pygments]` first on `PATH` before compiling:

```sh
uv venv
uv pip install latexminted "catppuccin[pygments]"
export PATH="$PWD/.venv/bin:$PATH"
```

## Installation

Install the theme files into your user TeX tree from the repository root:

```sh
l3build install
```

Check that TeX can find the installed theme:

```sh
kpsewhich beamerthemeslidemint.sty
```

`slidemint` installs only the slide theme. Install `macromint` and `figmint`
from their own repositories if your deck loads them.

## Usage

```tex
\documentclass[notheorems]{beamer}
\usetheme[palette = latte]{slidemint}
\usepackage{macromint}
\usepackage{figmint}
\slidemintsetup{
  footer-left = {\textcopyright~Author, 2026. Site: example.org}
}

\title{Talk title}
\author{Author}

\begin{document}
\maketitle

\begin{frame}
  \frametitle{Frame title}
  Content
\end{frame}

\begin{frame}[fragile]
  \frametitle{Code}
  \begin{minted}{python}
def loss(theta):
    return norm(theta)
  \end{minted}
\end{frame}

\begin{frame}
  \frametitle{Citations}
  In-text citations use natbib: \citep{mucsanyi2026slidemint}.
\end{frame}

\begin{frame}[allowframebreaks]
  \frametitle{References}
  \bibliographystyle{plainnat}
  \bibliography{references}
\end{frame}
\end{document}
```

Available palette values are `latte`, `frappe`, `macchiato`, and `mocha`.
These select the matching minted style names: `catppuccin-latte`,
`catppuccin-frappe`, `catppuccin-macchiato`, and `catppuccin-mocha`.
When `figmint` is loaded, slidemint applies the same palette to figure styles.

Use `\SlidemintTextbf`, `\SlidemintTextit`, and `\SlidemintEmph` for colored
slide emphasis. Core LaTeX `\textbf`, `\textit`, and `\emph` keep their normal
meaning.

Slidemint loads `natbib` in author-year round mode. Use `\citep` for
parenthetical citations, `\citet` for textual citations, and native BibTeX
commands on a final reference frame.

Slidemint owns slide appearance only. Math notation belongs to the standalone
`macromint` package, and figure styles belong to the standalone `figmint`
package.

## Tests

Run:

```sh
l3build check
```

## License

Apache 2.0.
