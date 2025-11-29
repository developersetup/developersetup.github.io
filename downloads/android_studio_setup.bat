@echo off
setlocal enabledelayedexpansion

:: ============================================
::          ANDROID STUDIO SETUP TOOL
:: ============================================

cls
echo ====================================================
echo                ANDROID STUDIO INSTALLER
echo ====================================================
echo 1. Install Android Studio
echo 2. Uninstall Android Studio
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ====================================================
::               INSTALL ANDROID STUDIO
:: ====================================================
:install
cls
echo ===============================
echo     INSTALLING ANDROID STUDIO
echo ===============================

echo Fetching latest Android Studio download URL...

:: Official download link always points to latest stable Windows EXE
set "AS_URL=https://redirector.gvt1.com/edgedl/android/studio/install/latest/windows/android-studio-latest.exe"

echo Downloading Android Studio...
powershell -command "try { Invoke-WebRequest '%AS_URL%' -OutFile 'android_studio.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to download Android Studio installer.
    pause
    exit /b
)

echo Installing Android Studio silently...
start /wait "" android_studio.exe /S
del android_studio.exe

echo.
echo ===============================================
echo Android Studio installed successfully!
echo You can launch it from the Start Menu.
echo ===============================================
pause
exit /b



:: ====================================================
::               UNINSTALL ANDROID STUDIO
:: ====================================================
:uninstall
cls
echo ===============================
echo   UNINSTALLING ANDROID STUDIO
echo ===============================

:: Find uninstall entry
set ASID=

for /f "tokens=2 delims=={}" %%i in (
    'wmic product where "name like 'Android Studio%%'" get IdentifyingNumber /value 2^>nul'
) do (
    set ASID=%%i
)

if "%ASID%"=="" (
    echo Android Studio was not found via MSI uninstall.
) else (
    echo Removing Android Studio...
    msiexec /x %ASID% /quiet
)

echo Deleting leftover config folders...
rmdir /s /q "%LOCALAPPDATA%\Google\AndroidStudio*" 2>nul
rmdir /s /q "%APPDATA%\Google\AndroidStudio*" 2>nul
rmdir /s /q "%USERPROFILE%\.android" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle" 2>nul

echo.
echo Android Studio has been removed.
pause
exit /b
