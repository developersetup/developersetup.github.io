@echo off
setlocal enabledelayedexpansion

:: ============================================
::         KUBECTL CLI SETUP TOOL
:: ============================================

cls
echo ====================================================
echo               KUBECTL INSTALLER TOOL
echo ====================================================
echo 1. Install kubectl
echo 2. Uninstall kubectl
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ====================================================
::                INSTALL KUBECTL
:: ====================================================
:install
cls
echo ===============================
echo        INSTALLING KUBECTL
echo ===============================
echo Enter kubectl Version (Example: 1.29.2)
echo Leave blank to install LATEST stable version.
echo.
set /p VER="Version: "

if "%VER%"=="" (
    echo Detecting latest stable version...
    powershell -command "(Invoke-WebRequest 'https://storage.googleapis.com/kubernetes-release/release/stable.txt').Content" > kube_latest.txt

    set /p VER=<kube_latest.txt
    del kube_latest.txt

    if "%VER%"=="" (
        echo ERROR: Could not detect latest kubectl version.
        pause
        exit /b
    )
)

:: Ensure version starts with v
if "%VER:~0,1%"=="v" (
    set KVER=%VER%
) else (
    set KVER=v%VER%
)

set "KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/%KVER%/bin/windows/amd64/kubectl.exe"

echo.
echo Download URL:
echo %KUBECTL_URL%

echo.
echo Downloading kubectl %KVER% ...
powershell -command "try { Invoke-WebRequest '%KUBECTL_URL%' -OutFile 'kubectl.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to download kubectl.
    pause
    exit /b
)

echo Installing kubectl...
mkdir "C:\kubectl" 2>nul
move /y kubectl.exe "C:\kubectl\" >nul

echo Adding C:\kubectl to PATH...
setx PATH "%PATH%;C:\kubectl" >nul

echo.
echo Verifying installation...
"C:\kubectl\kubectl.exe" version --client

echo.
echo ====================================================
echo kubectl %KVER% installed successfully!
echo Location: C:\kubectl\kubectl.exe
echo ====================================================
pause
exit /b



:: ====================================================
::               UNINSTALL KUBECTL
:: ====================================================
:uninstall
cls
echo ===============================
echo     UNINSTALLING KUBECTL
echo ===============================

if exist "C:\kubectl\kubectl.exe" (
    del /f /q "C:\kubectl\kubectl.exe"
    rmdir /s /q "C:\kubectl"
)

echo Removing PATH entry (restart required)...

echo.
echo ====================================================
echo kubectl has been removed.
echo Restart your system to refresh PATH.
echo ====================================================
pause
exit /b
