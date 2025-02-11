# Md2Pdf

A simple Markdown to Pdf converter inside Neovim.

https://github.com/user-attachments/assets/6d782d02-e25a-4053-9b6d-f2aa737635f4

<br>

## Dependencies

* [pandoc](https://pandoc.org/)
* Optional (if you want to use other pdf engine other than pdflatex):
   - texlive-luatex (for lualatex)
   - texlive-xetex (for xelatex)

Run `:checkhealth Md2Pdf` after installing to check if dependencies are installed.

**Recommended Pdf Viewers:**

* [zathura](https://pwmt.org/projects/zathura/)
* Or any pdf viewers that updates whenever changes are applied.

<br>

## To Do:

* [x] Support multiple buffer/file conversion in one NeoVim session.
* [x] Support YAML metadata template file.
* [x] Improve config handling.

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

## Configuration

```lua
require("Md2Pdf").setup({
   pdf_engine = "pdflatex" -- pdflatex, lualatex, or xelatex
   yaml_template_path = nil
})
```

<br>

## Usage

Start converting Markdown (*.md) file to Pdf after saving or writing the file. The Pdf is
located in the same directory as the Markdown file.

```
:Md2Pdf
:Md2Pdf start
```

Stop the auto-converting after saving or writing the file.

```
:Md2Pdf stop
```

Convert manually.

```
:Md2Pdf convert
```

<br>

## Variable specification (-V flag)

> [!NOTE]
> Read the pandoc documentation or Google it to know more about variables.

Add **Variables** in the Markdown file by adding YAML metadata blocks at the top.

```markdown
---
header-includes:
- \usepackage{fontspec}

geometry:
- margin=1cm

fontsize: 12pt
monofont: "FiraCode Nerd Font"
...

# Markdown Title
```

Or create a YAML template file and place the template path in the config's
`yaml_template_path`.

```lua
require("Md2Pdf").setup({
   pdf_engine = "pdflatex" -- pdflatex, lualatex, or xelatex
   yaml_template_path = "/home/user/template.yml"
})
```

