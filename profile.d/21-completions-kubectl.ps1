if (Get-Command kubectl -ErrorAction SilentlyContinue) {
  kubectl completion powershell | Out-String | Invoke-Expression
}