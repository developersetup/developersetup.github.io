@echo off
setlocal enabledelayedexpansion

:: ================================
::         PYTHON SETUP TOOL
:: ================================

cls
echo =========================================
echo                PYTHON
echo =========================================
echo 1. Install Python
echo 2. Uninstall Python
echo 3. Exit
echo =========================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b


:: ================================
::              INSTALL
:: ================================
:install
cls
echo ===============================
echo         PYTHON INSTALLER
echo ===============================
echo Enter Python Version (example: 3.12.2)
echo Leave blank to install LATEST version
echo ===============================
set /p VERSION="Version: "

if "%VERSION%"=="" (
    echo Detecting latest Python version...
    powershell -command "(Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/').Links | ? { $_.href -match '^[0-9]+\.[0-9]+\.[0-9]+/$' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.TrimEnd('/') }" > latest.txt

    set /p VERSION=<latest.txt
    del latest.txt

    if "%VERSION%"=="" (
        echo.
        echo ERROR: Could not detect latest Python version!
        pause
        exit /b
    )
)

set "PY_URL=https://www.python.org/ftp/python/%VERSION%/python-%VERSION%-amd64.exe"

echo.
echo Download URL:
echo %PY_URL%
echo.

echo Downloading Python %VERSION% ...
powershell -command "try { Invoke-WebRequest '%PY_URL%' -OutFile 'python_installer.exe' -ErrorAction Stop } catch { exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to download Python!
    pause
    exit /b
)

echo Installing Python silently...
python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
del python_installer.exe

echo.
echo =========================================
echo Python %VERSION% Installed Successfully!
echo Python has been added to PATH.
echo Restart your terminal to use python command.
echo =========================================
pause
exit /b



:: ================================
::             UNINSTALL
:: ================================
:uninstall
cls
echo Searching for installed Python packages...

powershell -command "Get-WmiObject -Query \"SELECT * FROM Win32_Product WHERE Name LIKE 'Python%'\" | ForEach-Object { $_.Uninstall() }"

echo.
echo Python uninstalled (if found).
echo You may restart your PC to refresh PATH.
pause
exit /b
