<#
.SYNOPSIS
  Membangun aplikasi Undian untuk Windows lalu membungkusnya menjadi installer Setup.exe.

.DESCRIPTION
  Langkah:
    1. flutter build windows --release dengan alamat server (SERVER_URL) yang ditanam di aplikasi
    2. menyalin runtime Visual C++ ke samping undian.exe, supaya laptop tanpa
       "Microsoft Visual C++ Redistributable" tetap bisa menjalankan aplikasi
    3. membuat gambar wizard installer dari tool/generate_icons.dart
    4. mengompilasi windows/installer/undian.iss dengan Inno Setup 6

  Hasil: build\installer\Undian-Setup-<versi>.exe. Versi diambil dari pubspec.yaml.
  Butuh: Flutter, Visual Studio 2022 (workload "Desktop development with C++"), Inno Setup 6.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\build_windows_installer.ps1 -ServerUrl https://api.undian.contoh.co.id/

.EXAMPLE
  # Uji lokal terhadap server di laptop ini
  powershell -ExecutionPolicy Bypass -File tool\build_windows_installer.ps1 -ServerUrl http://localhost:8080/
#>
param(
  # Alamat API Serverpod, mis. https://api.undian.contoh.co.id/ (sama dengan API_DOMAIN di deploy/.env).
  [Parameter(Mandatory = $true)]
  [string] $ServerUrl,

  # Lewati flutter build (pakai hasil build sebelumnya). Hanya untuk mengulang langkah installer.
  [switch] $SkipBuild
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$appDir = Split-Path $PSScriptRoot -Parent
Set-Location $appDir

function Step([string] $text) { Write-Host "`n==> $text" -ForegroundColor Cyan }

# --- Alamat server -----------------------------------------------------------------------------
if (-not $ServerUrl.EndsWith('/')) { $ServerUrl += '/' }
$uri = $null
if (-not [Uri]::TryCreate($ServerUrl, [UriKind]::Absolute, [ref] $uri) -or $uri.Scheme -notin @('http', 'https')) {
  throw "Alamat server tidak valid: $ServerUrl (contoh: https://api.undian.contoh.co.id/)"
}
$isLocal = $uri.Host -in @('localhost', '127.0.0.1', '::1')
if ($uri.Scheme -ne 'https' -and -not $isLocal) {
  throw "Alamat server harus memakai https:// (http hanya boleh untuk localhost): $ServerUrl"
}

# --- Versi dari pubspec.yaml -------------------------------------------------------------------
$match = Select-String -Path pubspec.yaml -Pattern '^version:\s*(\d+\.\d+\.\d+)' | Select-Object -First 1
if (-not $match) { throw 'Baris "version: x.y.z+n" tidak ditemukan di pubspec.yaml' }
$version = $match.Matches[0].Groups[1].Value

$release = Join-Path $appDir 'build\windows\x64\runner\Release'
$outputDir = Join-Path $appDir 'build\installer'
$wizardDir = Join-Path $outputDir 'wizard'

Write-Host "Undian $version  |  server: $ServerUrl"

# --- 1. Build aplikasi -------------------------------------------------------------------------
if (-not $SkipBuild) {
  Step 'Build aplikasi Windows (release)'
  # Folder hasil dikosongkan dulu supaya file lama tidak ikut terbungkus ke installer.
  if (Test-Path $release) { Remove-Item $release -Recurse -Force }
  & flutter build windows --release "--dart-define=SERVER_URL=$ServerUrl"
  if ($LASTEXITCODE -ne 0) { throw "flutter build windows gagal (kode $LASTEXITCODE)" }
}
if (-not (Test-Path (Join-Path $release 'undian.exe'))) {
  throw "undian.exe tidak ditemukan di $release. Jalankan tanpa -SkipBuild."
}

# --- 2. Runtime Visual C++ ---------------------------------------------------------------------
Step 'Menyalin runtime Visual C++'
$runtimeDlls = @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')
$crtDir = $null
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path $vswhere) {
  $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  if ($vsPath) {
    $crtDir = Get-ChildItem (Join-Path $vsPath 'VC\Redist\MSVC') -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match '^\d' } |
      Sort-Object { [Version] $_.Name } -Descending |
      ForEach-Object { Get-ChildItem (Join-Path $_.FullName 'x64') -Directory -Filter 'Microsoft.VC*.CRT' -ErrorAction SilentlyContinue } |
      Select-Object -First 1 -ExpandProperty FullName
  }
}
if (-not $crtDir) {
  # Cadangan: salinan yang terpasang di Windows laptop ini.
  $crtDir = Join-Path $env:SystemRoot 'System32'
  Write-Warning "Folder redistributable Visual Studio tidak ditemukan; memakai DLL dari $crtDir"
}
foreach ($dll in $runtimeDlls) {
  $source = Join-Path $crtDir $dll
  if (-not (Test-Path $source)) { throw "$dll tidak ditemukan di $crtDir" }
  Copy-Item $source $release -Force
}
Write-Host "Dari: $crtDir"

# --- 3. Gambar wizard --------------------------------------------------------------------------
Step 'Membuat gambar wizard installer'
& dart run tool/generate_icons.dart --wizard $wizardDir
if ($LASTEXITCODE -ne 0) { throw "generate_icons.dart gagal (kode $LASTEXITCODE)" }

# --- 4. Inno Setup -----------------------------------------------------------------------------
Step 'Mengompilasi installer (Inno Setup)'
$iscc = @(
  (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
  (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe'),
  (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
  throw 'Inno Setup 6 belum terpasang. Unduh dari https://jrsoftware.org/isdl.php lalu jalankan ulang skrip ini.'
}
& $iscc /Q "/DAppVersion=$version" "/DSourceDir=$release" "/DWizardDir=$wizardDir" "/DOutputDir=$outputDir" 'windows\installer\undian.iss'
if ($LASTEXITCODE -ne 0) { throw "Inno Setup gagal (kode $LASTEXITCODE)" }

$setup = Get-Item (Join-Path $outputDir "Undian-Setup-$version.exe")
$hash = (Get-FileHash $setup.FullName -Algorithm SHA256).Hash
Write-Host ''
Write-Host 'Installer siap:' -ForegroundColor Green
Write-Host "  File   : $($setup.FullName)"
Write-Host ("  Ukuran : {0:N1} MB" -f ($setup.Length / 1MB))
Write-Host "  SHA256 : $hash"
Write-Host "  Server : $ServerUrl"
