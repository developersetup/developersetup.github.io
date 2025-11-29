@echo off
setlocal enabledelayedexpansion

:: ============================================
::              GIT SETUP TOOL
:: ============================================

cls
echo ===============================================
echo                  GIT INSTALLER
echo ===============================================
echo 1. Install Git
echo 2. Uninstall Git
echo 3. Exit
echo ===============================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b


:: ============================================
::                INSTALL GIT
:: ============================================
:install
cls
echo ===============================
echo          INSTALL GIT
echo ===============================
echo Enter Git version (example: 2.44.0)
echo Leave blank to install LATEST version
echo ===============================
set /p GVER="Git Version: "

if "%GVER%"=="" (
    echo Detecting latest Git version...
    powershell -command "(Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/latest').Content" > gitver.txt

    for /f "tokens=2 delims=v>< """ %%a in ('findstr /i "windows" gitver.txt') do set GVER=%%a
    del gitver.txt

    if "%GVER%"=="" (
        echo ERROR: Failed to detect latest Git version.
        pause
        exit /b
    )
)

set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v%GVER%/Git-%GVER%-64-bit.exe"

echo.
echo Download URL:
echo %GIT_URL%

echo.
echo Downloading Git %GVER% ...
powershell -command "try { Invoke-WebRequest '%GIT_URL%' -OutFile 'gitsetup.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Git installer!
    pause
    exit /b
)

echo Installing Git silently...
start /wait "" gitsetup.exe /VERYSILENT /NORESTART
del gitsetup.exe

echo.
echo ===============================================
echo Git %GVER% installed successfully!
echo Restart terminal to use git command.
echo ===============================================
pause
exit /b



:: ============================================
::               UNINSTALL GIT
:: ============================================
:uninstall
cls
echo ===============================
echo        UNINSTALLING GIT
echo ===============================

set GITID=

for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Git%%'" get IdentifyingNumber /value 2^>nul') do (
    set GITID=%%i
)

if "%GITID%"=="" (
    echo Git not found on this system.
    pause
    exit /b
)

echo Uninstalling Git...
msiexec /x %GITID% /quiet

echo Git has been removed.
echo Restart recommended to refresh PATH.
pause
exit /b
