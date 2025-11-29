@echo off
setlocal enabledelayedexpansion

:: ============================================
::              POSTMAN SETUP TOOL
:: ============================================

cls
echo ====================================================
echo                POSTMAN INSTALLER TOOL
echo ====================================================
echo 1. Install Postman
echo 2. Uninstall Postman
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ====================================================
::             INSTALL POSTMAN
:: ====================================================
:install
cls
echo ===============================
echo        INSTALLING POSTMAN
echo ===============================

echo Downloading latest Postman Desktop installer...

set "POSTMAN_URL=https://dl.pstmn.io/download/latest/win64"

powershell -command "try { Invoke-WebRequest '%POSTMAN_URL%' -OutFile 'postman.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Postman installer!
    pause
    exit /b
)

echo Installing Postman silently...
start /wait "" postman.exe /S
del postman.exe

echo.
echo ====================================================
echo Postman installed successfully!
echo Launch from Start Menu or Desktop.
echo ====================================================
pause
exit /b



:: ====================================================
::            UNINSTALL POSTMAN
:: ====================================================
:uninstall
cls
echo ===============================
echo      UNINSTALLING POSTMAN
echo ===============================

echo Searching for Postman installation directory...

:: Default installation path
set "POSTDIR=%LOCALAPPDATA%\Postman"

if exist "%POSTDIR%" (
    echo Removing Postman directory...
    rmdir /s /q "%POSTDIR%"
) else (
    echo Postman installation directory not found.
)

echo Removing shortcuts (if any)...
del "%USERPROFILE%\Desktop\Postman.lnk" 2>nul
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Postman.lnk" 2>nul

echo.
echo ====================================================
echo Postman has been removed completely.
echo ====================================================
pause
exit /b
