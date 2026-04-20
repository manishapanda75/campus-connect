# ============================================================
#  Campus Connect - Flutter Auto-Setup Script
#  Run this ONCE after the Flutter SDK download completes
# ============================================================

$FlutterZip  = "$env:USERPROFILE\flutter_sdk.zip"
$FlutterDir  = "C:\flutter"
$FlutterBin  = "C:\flutter\flutter\bin"
$ProjectDir  = "C:\Users\panda\OneDrive\Desktop\hcktn\campus_connect"

Write-Host "`n=== Campus Connect Flutter Setup ===" -ForegroundColor Cyan

# ── Step 1: Check if download is complete ──────────────────
$job = Get-BitsTransfer | Where-Object {$_.DisplayName -eq "BITS Transfer"} | Select-Object -First 1
if ($job -and $job.JobState -eq "Transferring") {
    $pct = [math]::Round($job.BytesTransferred / $job.BytesTotal * 100, 1)
    Write-Host "[!] Flutter SDK still downloading: $pct% complete" -ForegroundColor Yellow
    Write-Host "    Run this script again once download is complete." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $FlutterZip)) {
    Write-Host "[!] Flutter SDK zip not found at $FlutterZip" -ForegroundColor Red
    Write-Host "    Re-run the download command in SETUP.md" -ForegroundColor Red
    exit 1
}

$zipSize = (Get-Item $FlutterZip).Length
if ($zipSize -lt 100MB) {
    Write-Host "[!] Download seems incomplete ($([math]::Round($zipSize/1MB,1)) MB). Please wait." -ForegroundColor Yellow
    exit 1
}

# ── Step 2: Extract Flutter ─────────────────────────────────
Write-Host "`n[1/5] Extracting Flutter SDK to $FlutterDir ..." -ForegroundColor Green
if (Test-Path $FlutterDir) {
    Write-Host "      Flutter directory already exists, skipping extract." -ForegroundColor Gray
} else {
    Expand-Archive -Path $FlutterZip -DestinationPath $FlutterDir -Force
    Write-Host "      Extracted!" -ForegroundColor Green
}

# ── Step 3: Add to PATH ─────────────────────────────────────
Write-Host "[2/5] Adding Flutter to PATH..." -ForegroundColor Green
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$FlutterBin*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$FlutterBin", "User")
    $env:PATH += ";$FlutterBin"
    Write-Host "      Added $FlutterBin to PATH" -ForegroundColor Green
} else {
    Write-Host "      Already in PATH" -ForegroundColor Gray
}

# ── Step 4: Flutter Doctor ───────────────────────────────────
Write-Host "[3/5] Running flutter doctor..." -ForegroundColor Green
& "$FlutterBin\flutter.bat" doctor --android-licenses 2>&1 | Select-String -NotMatch "^$"

# ── Step 5: Install dependencies ────────────────────────────
Write-Host "[4/5] Installing Dart dependencies..." -ForegroundColor Green
Set-Location $ProjectDir
& "$FlutterBin\flutter.bat" pub get

# ── Step 6: Install FlutterFire CLI ─────────────────────────
Write-Host "[5/5] Installing FlutterFire CLI..." -ForegroundColor Green
& "$FlutterBin\dart.bat" pub global activate flutterfire_cli

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Run 'flutterfire configure' to link your Firebase project" -ForegroundColor Yellow
Write-Host "  2. Add your Gemini API key to lib/services/chat_service.dart" -ForegroundColor Yellow
Write-Host "  3. Run 'flutter run' to launch the app" -ForegroundColor Yellow
Write-Host ""
Write-Host "See SETUP.md for detailed instructions." -ForegroundColor Gray
