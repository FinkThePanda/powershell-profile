function git-status {
  [CmdletBinding()]
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
  )

  git status @Arguments
}

function git-status-all {
  [CmdletBinding()]
  param(
    [Parameter()]
    [string]$Path = ".",

    [Parameter()]
    [switch]$Recurse
  )

  $directories = Get-ChildItem -Path $Path -Directory -Recurse:$Recurse |
    Where-Object { Test-Path (Join-Path $_.FullName ".git") }

  foreach ($dir in $directories) {
    Write-Host "=== $($dir.FullName) ===" -ForegroundColor Cyan
    Push-Location $dir.FullName
    try {
      git-status --short --branch
    }
    finally {
      Pop-Location
    }
    Write-Host
  }
}

function git-branch {
  [CmdletBinding()]
  param()

  $branch = git branch --show-current

  if ([string]::IsNullOrWhiteSpace($branch)) {
    $sha = git rev-parse --short HEAD 2>$null
    if ($sha) {
      "detached@$sha"
    }
    else {
      "(unknown)"
    }
  }
  else {
    $branch
  }
}

function git-branch-all {
  [CmdletBinding()]
  param(
    [Parameter()]
    [string]$Path = ".",

    [Parameter()]
    [switch]$Recurse
  )

  $directories = Get-ChildItem -Path $Path -Directory -Recurse:$Recurse |
    Where-Object { Test-Path (Join-Path $_.FullName ".git") }

  foreach ($dir in $directories) {
    Push-Location $dir.FullName
    try {
      $branch = git-branch
      Write-Host "$($dir.FullName): $branch" -ForegroundColor Cyan
    }
    finally {
      Pop-Location
    }
  }
}

function gsr {
  git-status-all -Recurse
}

function gbar {
  git-branch-all -Recurse
}

Set-Alias gs git-status
Set-Alias gsa git-status-all
Set-Alias gb git-branch
Set-Alias gba git-branch-all