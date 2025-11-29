@echo off
setlocal enabledelayedexpansion

:: ============================================
::          VISUAL STUDIO CODE SETUP
:: ============================================

cls
echo ===============================================
echo          VISUAL STUDIO CODE INSTALLER
echo ===============================================
echo 1. Install VS Code
echo 2. Uninstall VS Code
echo 3. Exit
echo ===============================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ============================================
::              INSTALL VSCODE
:: ============================================
:install
cls
echo ===============================
echo      INSTALLING VS CODE
echo ===============================

set "VSCODE_URL=https://update.code.visualstudio.com/latest/win32-x64/stable"

echo Downloading Visual Studio Code...
powershell -command "try { Invoke-WebRequest '%VSCODE_URL%' -OutFile 'vscode.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download VS Code installer!
    pause
    exit /b
)

echo Installing VS Code silently...
start /wait "" vscode.exe /VERYSILENT /NORESTART
del vscode.exe

echo.
echo ===============================================
echo Visual Studio Code installed successfully!
echo ===============================================
pause
exit /b



:: ============================================
::             UNINSTALL VSCODE
:: ============================================
:uninstall
cls
echo ===============================
echo     UNINSTALLING VS CODE
echo ===============================

set VSCODEID=

for /f "tokens=2 delims=={}" %%i in (
    'wmic product where "name like 'Visual Studio Code%%'" get IdentifyingNumber /value 2^>nul'
) do (
    set VSCODEID=%%i
)

if "%VSCODEID%"=="" (
    echo VS Code not found on this system.
    pause
    exit /b
)

echo Uninstalling VS Code...
msiexec /x %VSCODEID% /quiet

echo.
echo VS Code has been removed.
pause
exit /b
