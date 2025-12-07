param(
    [int]$ProductPort = 8001,
    [int]$OrderPort = 8002,
    [int]$ProductDaprHttp = 3500,
    [int]$OrderDaprHttp = 3501,
    [string]$ComponentsPath = "$PSScriptRoot/../dapr/components/local"
)

# Ensure Redis is running locally on 6379. If not, start one:
#   docker run --rm -p 6379:6379 redis:7-alpine

$root = Resolve-Path "$PSScriptRoot/.."
$orderDir = Join-Path $root "services/order-service"
$productDir = Join-Path $root "services/product-service"
$components = Resolve-Path $ComponentsPath

# Ensure UTF-8 output to avoid emoji/encoding crashes on Windows consoles
$env:PYTHONUTF8 = "1"

# Disable Dapr remote scheduler noise locally
$env:DAPR_RUNTIME_DISABLE_REMOTE_SCHEDULER = "true"

# Require dapr CLI
if (-not (Get-Command dapr -ErrorAction SilentlyContinue)) {
    Write-Error "dapr CLI not found on PATH. Install with 'winget install Dapr.CLI' then rerun."
    exit 1
}

$processes = @()

$processes += Start-Process -FilePath "dapr" -ArgumentList @(
    "run",
    "--app-id", "order-service",
    "--app-port", $OrderPort,
    "--dapr-http-port", $OrderDaprHttp,
    "--resources-path", $components,
    "--",
    "uv", "run", "fastapi", "run", "src/main.py",
    "--host", "0.0.0.0",
    "--port", $OrderPort
) -WorkingDirectory $orderDir -PassThru

$processes += Start-Process -FilePath "dapr" -ArgumentList @(
    "run",
    "--app-id", "product-service",
    "--app-port", $ProductPort,
    "--dapr-http-port", $ProductDaprHttp,
    "--resources-path", $components,
    "--",
    "uv", "run", "fastapi", "run", "src/main.py",
    "--host", "0.0.0.0",
    "--port", $ProductPort
) -WorkingDirectory $productDir -PassThru

$processes | ForEach-Object {
    Write-Host "Started $($_.Id): $($_.StartInfo.FileName) $($_.StartInfo.Arguments)"
}

Write-Host "To stop: Stop-Process -Id $($processes.Id -join ' ')" -ForegroundColor Yellow
