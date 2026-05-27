# Run a postman collection

function collection {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("cinema-local", "cinema-dev")]
        [string]$Target,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$RemainingArgs
    )

    $cinema = Join-Path $HOME "University/wao-project/artifacts/postman"

    $targets = @{
        "cinema-local" = Join-Path $cinema "cinema-system-local.postman_collection.json"
        "cinema-dev"   = Join-Path $cinema "cinema-system-deployed.postman_collection.json"
    }

    $path = $targets[$Target]

    if (-not (Test-Path $path)) {
        Write-Error "Collection file not found: $path"
        return
    }

    postman collection run $path @RemainingArgs
}