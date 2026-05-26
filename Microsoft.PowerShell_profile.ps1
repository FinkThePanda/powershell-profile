$profileRoot = Split-Path -Parent $PROFILE
$profileParts = Join-Path $profileRoot "profile.d"

if (Test-Path $profileParts) {
  Get-ChildItem -Path $profileParts -Filter "*.ps1" |
    Sort-Object Name |
    ForEach-Object {
      try {
        . $_.FullName
      }
      catch {
        Write-Warning "Failed to load profile script: $($_.FullName)"
        Write-Warning $_.Exception.Message
      }
    }
}
