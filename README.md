# Md2Pdf

A Markdown to Pdf converter inside Neovim.

> [!WARNING]
> Currently in Beta state.

<br>

**Dependencies:**

* [pandoc](https://pandoc.org/)
* Optional (if you want to use other pdf engine other than pdflatex):
   - texlive-luatex (for lualatex)
   - texlive-xetex (for xelatex)

**Recommended Pdf Viewers:**

* [zathura](https://pwmt.org/projects/zathura/)
* Or any pdf viewers that updates whenever changes are applied.

<br>

## To Do:

* [x] Support multiple buffer/file conversion in one NeoVim session.

<br>

## Installation

**Lazy:**

```lua
{
   "alexxGmZ/Md2Pdf",
   cmd = "Md2Pdf"
}
```

<br>

## Usage

Start converting Markdown (*.md) file to Pdf after saving or writing the file. The Pdf is
located in the same directory as the Markdown file.

```
:Md2Pdf
:Md2Pdf start
```

Stop converting.

```
:Md2Pdf stop
```

Convert manually.

```
:Md2Pdf convert
```

Add **Variables** in the Markdown file by adding YAML metadata blocks at the top.

> [!NOTE]
> Just read the pandoc documentation or Google it to know more.

```markdown
---
header-includes:
- \usepackage{fontspec}

geometry:
- margin=1cm

fontsize: 12pt
monofont: "FiraCode Nerd Font"
...
```

<br>

## Configuration

```lua
require("Md2Pdf").setup({
   pdf_engine = "pdflatex" -- pdflatex, lualatex, or xelatex
})
```
