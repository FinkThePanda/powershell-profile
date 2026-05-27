# Use to print or open documentation for terminal commands.
# We use Glow and Neovim to view Markdown files in the terminal.
# Examples:
#   doc --glow doc
#   doc --nvim postman
#   doc --list
function doc {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Mode,

        [Parameter(Position = 1)]
        [string]$Name
    )

    $docsRoot = Join-Path $HOME "Documents/PowerShell/.documentation"

    $targets = @{
        "doc" = Join-Path $docsRoot "doc.md"
        "postman" = Join-Path $docsRoot "postman.md"
    }

    if (-not $Mode) {
        Write-Error "Usage: doc [--glow|--nvim] <name> or doc --list"
        return
    }

    if ($Mode -notin @('--glow', '--nvim', '--list')) {
        Write-Error "Unknown mode '$Mode'. Use --glow, --nvim, or --list."
        return
    }

    if ($Mode -eq '--list') {
        if ($targets.Count -eq 0) {
            Write-Host "No documentation targets configured."
            return
        }

        Write-Host "Available documentation targets:"
        $targets.Keys |
            Sort-Object |
            ForEach-Object {
                Write-Host " - $_"
            }

        return
    }

    if (-not $Name) {
        Write-Error "Usage: doc [--glow|--nvim] <name> or doc --list"
        return
    }

    if ($targets.ContainsKey($Name)) {
        $file = $targets[$Name]
    } else {
        $file = Join-Path $docsRoot "$Name.md"
    }

    if (-not (Test-Path $file)) {
        Write-Error "Documentation file not found for '$Name': $file"
        return
    }

    switch ($Mode) {
        '--glow' { glow $file }
        '--nvim' { nvim $file }
    }
}