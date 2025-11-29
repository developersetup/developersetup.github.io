@echo off
setlocal enabledelayedexpansion

:: ================================
::     MAVEN INSTALLER TOOL
:: ================================

cls
echo =========================================
echo             MAVEN SETUP TOOL
echo =========================================
echo 1. Install Maven
echo 2. Uninstall Maven
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
echo         MAVEN INSTALLER
echo ===============================
echo Enter Maven Version (example: 3.9.6)
echo Leave blank to install LATEST
echo ===============================
set /p VERSION="Version: "

if "%VERSION%"=="" (
    echo Detecting latest Maven version...
    powershell -command "(Invoke-WebRequest -Uri 'https://dlcdn.apache.org/maven/maven-3/').Links | ? { $_.href -match '^[0-9]+\.[0-9]+\.[0-9]+/$' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.TrimEnd('/') }" > latest.txt

    set /p VERSION=<latest.txt
    del latest.txt

    if "%VERSION%"=="" (
        echo.
        echo ERROR: Could not detect the latest Maven version!
        echo Installation aborted.
        pause
        exit /b
    )
)

set "DOWNLOAD_URL=https://dlcdn.apache.org/maven/maven-3/%VERSION%/binaries/apache-maven-%VERSION%-bin.zip"

echo.
echo Download URL:
echo %DOWNLOAD_URL%
echo.

echo Downloading Maven %VERSION% ...
powershell -command "try { Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile 'maven.zip' -ErrorAction Stop } catch { exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to download Maven!
    echo.
    pause
    exit /b
)

echo Extracting...
powershell -command "Expand-Archive 'maven.zip' -DestinationPath 'C:\Tools' -Force"
del maven.zip

set "MAVEN_HOME=C:\Tools\apache-maven-%VERSION%"

echo Setting environment variables...
setx MAVEN_HOME "%MAVEN_HOME%" >nul
setx PATH "%PATH%;%MAVEN_HOME%\bin" >nul

echo.
echo =========================================
echo Maven %VERSION% Installed Successfully!
echo MAVEN_HOME = %MAVEN_HOME%
echo Restart your CMD or PC for PATH update.
echo =========================================
pause
exit /b

:: ================================
::           UNINSTALL
:: ================================
:uninstall
cls
echo Uninstalling Maven...

for /d %%D in ("C:\Tools\apache-maven-*") do (
    echo Removing %%D
    rmdir /s /q "%%D"
)

echo Removing environment variables...
reg delete "HKCU\Environment" /F /V MAVEN_HOME >nul 2>&1

echo.
echo Maven Uninstalled.
echo Restart PC to refresh PATH.
pause
exit /b
