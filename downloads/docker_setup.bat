@echo off
setlocal enabledelayedexpansion

:: ============================================
::             DOCKER DESKTOP SETUP TOOL
:: ============================================

cls
echo ====================================================
echo                 DOCKER DESKTOP INSTALLER
echo ====================================================
echo 1. Install Docker Desktop
echo 2. Uninstall Docker Desktop
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b


:: ====================================================
::             INSTALL DOCKER DESKTOP
:: ====================================================
:install
cls
echo ===============================
echo     INSTALLING DOCKER DESKTOP
echo ===============================

echo Checking Windows virtualization support...
dism.exe /online /get-features /format:table | findstr /i "VirtualMachinePlatform" >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Virtual Machine Platform is not enabled.
    echo Docker requires:
    echo  - Virtual Machine Platform
    echo  - Windows Subsystem for Linux (WSL2)
    echo.
    pause
)

echo Enabling WSL2 features (if not already enabled)...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >nul
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >nul

echo.
echo Downloading latest Docker Desktop...

set "DOCKER_URL=https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"

powershell -command "try { Invoke-WebRequest '%DOCKER_URL%' -OutFile 'docker_installer.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not download Docker Desktop installer.
    pause
    exit /b
)

echo Installing Docker Desktop silently...
start /wait "" docker_installer.exe install --quiet
del docker_installer.exe

echo.
echo ====================================================
echo Docker Desktop installed successfully!
echo You may need to restart your system.
echo ====================================================
pause
exit /b



:: ====================================================
::             UNINSTALL DOCKER DESKTOP
:: ====================================================
:uninstall
cls
echo ===============================
echo   UNINSTALLING DOCKER DESKTOP
echo ===============================

echo Checking for Docker Desktop installation...

set DOCKERID=

for /f "tokens=2 delims=={}" %%i in (
  'wmic product where "name like 'Docker%%'" get IdentifyingNumber /value 2^>nul'
) do (
  set DOCKERID=%%i
)

if "%DOCKERID%"=="" (
    echo Docker Desktop MSI entry not found.
) else (
    echo Uninstalling Docker Desktop...
    msiexec /x %DOCKERID% /quiet
)

echo Removing Docker data directories...
rmdir /s /q "%LOCALAPPDATA%\Docker" 2>nul
rmdir /s /q "%APPDATA%\Docker" 2>nul
rmdir /s /q "%PROGRAMDATA%\Docker" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Docker Desktop" 2>nul

echo.
echo ====================================================
echo Docker Desktop has been removed completely.
echo Restart your PC to finish cleanup.
echo ====================================================
pause
exit /b
