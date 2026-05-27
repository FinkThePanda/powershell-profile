# Read documentation in PowerShell

Use `doc` to open Markdown documentation from the terminal.

Documents can be viewed in one of two ways:
- `--glow`: render the Markdown in the terminal with Glow
- `--nvim`: open the Markdown file in Neovim
- `--list`: list available named documentation targets

## Usage

```powershell
doc [--glow|--nvim] <name>
doc --list
```

# Supported document root

```powershell
$HOME/Documents/PowerShell/.documentation
```

# Supported named targets

```powershell
doc      -> $HOME/Documents/PowerShell/.documentation/doc.md
postman  -> $HOME/Documents/PowerShell/.documentation/postman.md
```