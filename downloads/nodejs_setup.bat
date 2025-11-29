@echo off
setlocal enabledelayedexpansion

:: ================================
::         NODE.JS SETUP TOOL
:: ================================

cls
echo =========================================
echo                 NODE.JS
echo =========================================
echo 1. Install Node.js
echo 2. Uninstall Node.js
echo 3. Exit
echo =========================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b

:: ================================
::            INSTALL
:: ================================
:install
cls
echo ===============================
echo         NODE.JS INSTALLER
echo ===============================
echo Enter Node.js Version (example: 20.10.0)
echo Leave blank to install LATEST version
echo ===============================
set /p VERSION="Version: "

if "%VERSION%"=="" (
    echo Detecting latest Node.js version...
    powershell -command "(Invoke-WebRequest -Uri 'https://nodejs.org/dist/').Links | ? { $_.href -match '^v[0-9]+\.' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.Trim('/').Replace('v','') }" > latest.txt

    set /p VERSION=<latest.txt
    del latest.txt

    if "%VERSION%"=="" (
        echo.
        echo ERROR: Could not detect latest Node.js version!
        pause
        exit /b
    )
)

set "NODE_URL=https://nodejs.org/dist/v%VERSION%/node-v%VERSION%-x64.msi"

echo.
echo Download URL:
echo %NODE_URL%
echo.

echo Downloading Node.js %VERSION% ...
powershell -command "try { Invoke-WebRequest '%NODE_URL%' -OutFile 'node.msi' -ErrorAction Stop } catch { exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to download Node.js!
    pause
    exit /b
)

echo Installing Node.js silently...
msiexec /i node.msi /qn /norestart
del node.msi

echo Adding Node.js to PATH...
setx PATH "%PATH%;C:\Program Files\nodejs" >nul

echo.
echo =========================================
echo Node.js %VERSION% Installed Successfully!
echo Restart your terminal for PATH update.
echo =========================================
pause
exit /b

:: ================================
::           UNINSTALL
:: ================================
:uninstall
cls
echo Searching for Node.js MSI package...

set ID=

for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Node.js%%'" get IdentifyingNumber /value 2^>nul') do (
    set ID=%%i
)

if "%ID%"=="" (
    echo.
    echo Node.js not found in system.
    pause
    exit /b
)

echo Uninstalling Node.js...
msiexec /x %ID% /quiet

echo Node.js removed.
echo Restart recommended to refresh PATH.
pause
exit /b
