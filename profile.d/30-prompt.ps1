$scoopShims = Join-Path $HOME "scoop\shims"

if ((Test-Path $scoopShims) -and ($env:Path -notlike "*$scoopShims*")) {
  $env:Path = "$scoopShims;$env:Path"
}

$ohMyPosh = Join-Path $scoopShims "oh-my-posh.exe"

if (Test-Path $ohMyPosh) {
  & $ohMyPosh init pwsh --config "jandedobbeleer" | Invoke-Expression
}