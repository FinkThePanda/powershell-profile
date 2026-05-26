function note {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  $notesDir = Join-Path $HOME ".shower-thoughts"
  New-Item -ItemType Directory -Force -Path $notesDir | Out-Null
  nvim (Join-Path $notesDir $Name)
}