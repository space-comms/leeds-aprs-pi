@echo off
REM Leeds APRS Pi - Windows Flash Tool
REM Downloads latest image and helps user flash with Rufus

setlocal enabledelayedexpansion

echo.
echo  ____        _               _    ____  ____  ____      ____  _ 
echo ^| ^|   ___  ___  __^| ^|___   / \  ^|  _ \^|  _ \/ ___^|    ^|  _ \^(^)
echo ^| ^|  / _ \/ _ \/ _` / __^| / _ \ ^| ^|_^) ^| ^|_^) \___ \    ^| ^|_^) ^| ^|
echo ^| ^| ^|  __/  __/ ^(_^| \__ \/ ___ \^|  __/^|  _ ^< ___^) ^|___^|  __/^| ^|
echo ^|_^|  \___^\___^\__,_^|___/_/   \_\_^|   ^|_^| \_\____/___^|_^|   ^|_^|
echo.
echo Leeds APRS Pi - Flash Tool v1.2
echo ===============================

REM Check for internet connection
ping -n 1 github.com >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No internet connection. Please connect and try again.
    pause
    exit /b 1
)

REM Create downloads directory
if not exist "downloads" mkdir downloads
cd downloads

echo [INFO] Checking for latest release...

REM Download latest release info using PowerShell
powershell -Command "& {$releases = Invoke-RestMethod 'https://api.github.com/repos/space-comms/leeds-aprs-pi/releases/latest'; $imageAsset = $releases.assets | Where-Object {$_.name -like '*.img.gz'}; if ($imageAsset) { $imageAsset.browser_download_url | Out-File -FilePath 'download_url.txt' -Encoding ascii; $imageAsset.name | Out-File -FilePath 'image_name.txt' -Encoding ascii; Write-Host '[INFO] Latest version:' $releases.tag_name } else { Write-Host '[ERROR] No image found in latest release'; exit 1 }}"

if not exist "download_url.txt" (
    echo [ERROR] Could not find latest release. Please check internet connection.
    pause
    exit /b 1
)

set /p DOWNLOAD_URL=<download_url.txt
set /p IMAGE_NAME=<image_name.txt

echo [INFO] Latest image: %IMAGE_NAME%

REM Check if image already exists
if exist "%IMAGE_NAME%" (
    echo [INFO] Image already downloaded.
    set /p REDOWNLOAD="Re-download? (y/N): "
    if /i not "!REDOWNLOAD!"=="y" goto :flash
)

echo [INFO] Downloading %IMAGE_NAME%...
echo [INFO] This may take several minutes depending on your connection.

REM Download with PowerShell progress bar
powershell -Command "& {$ProgressPreference = 'Continue'; Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%IMAGE_NAME%' -UseBasicParsing}"

if not exist "%IMAGE_NAME%" (
    echo [ERROR] Download failed. Please try again.
    pause
    exit /b 1
)

echo [SUCCESS] Download complete!

:flash
echo.
echo ============================================
echo FLASHING INSTRUCTIONS
echo ============================================
echo.
echo 1. Download Rufus from: https://rufus.ie/
echo 2. Insert your SD card (8GB minimum)
echo 3. Run Rufus as Administrator
echo 4. Select your SD card in "Device"
echo 5. Click "SELECT" and choose: %cd%\%IMAGE_NAME%
echo 6. Click "START" and wait for completion
echo 7. Safely eject SD card
echo 8. Insert into Raspberry Pi and power on
echo.
echo ============================================
echo FIRST TIME SETUP
echo ============================================
echo.
echo 1. Wait 2-3 minutes for Pi to boot
echo 2. Connect to WiFi network: "Leeds-APRS-Setup"
echo 3. Password: "aprssetup"
echo 4. Open browser to: http://192.168.4.1
echo 5. Enter your callsign and location
echo 6. Connect to your home WiFi
echo 7. Access dashboard at: http://[pi-ip]:8080
echo.

REM Ask if user wants to open Rufus download page
set /p OPEN_RUFUS="Open Rufus download page? (Y/n): "
if /i not "!OPEN_RUFUS!"=="n" (
    start https://rufus.ie/
)

REM Ask if user wants to open image folder
set /p OPEN_FOLDER="Open image folder? (Y/n): "
if /i not "!OPEN_FOLDER!"=="n" (
    explorer /select,"%cd%\%IMAGE_NAME%"
)

echo.
echo [SUCCESS] Ready to flash! Follow the instructions above.
echo.
echo For support: https://github.com/space-comms/leeds-aprs-pi/issues
echo 73 de Leeds Space Comms!

pause