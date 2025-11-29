@echo off
setlocal enabledelayedexpansion

:: ============================================
::              MONGODB SETUP TOOL
:: ============================================

cls
echo ====================================================
echo                 MONGODB INSTALLER TOOL
echo ====================================================
echo 1. Install MongoDB
echo 2. Uninstall MongoDB
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ====================================================
::              INSTALL MONGODB
:: ====================================================
:install
cls
echo ===============================
echo       INSTALLING MONGODB
echo ===============================
echo Enter MongoDB Version (Example: 6.0.10)
echo Leave blank to install LATEST stable version.
echo.
set /p VER="Version: "

if "%VER%"=="" (
    echo Detecting latest MongoDB version...
    powershell -command "(Invoke-WebRequest 'https://www.mongodb.com/try/download/community').Content" > version.txt

    for /f "tokens=2 delims=<>" %%a in ('findstr /i "current version" version.txt') do set VER=%%a
    del version.txt

    if "%VER%"=="" (
        echo Could not fetch latest version, using stable version 6.0.10
        set VER=6.0.10
    )
)

set "MDB_URL=https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-%VER%.msi"

echo.
echo Download URL:
echo %MDB_URL%

echo.
echo Downloading MongoDB %VER% ...
powershell -command "try { Invoke-WebRequest '%MDB_URL%' -OutFile 'mongodb.msi' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to download MongoDB installer.
    pause
    exit /b
)

echo Installing MongoDB silently...
msiexec /i mongodb.msi /qn INSTALLLOCATION="C:\Program Files\MongoDB\Server\%VER%" ADDLOCAL="All"
del mongodb.msi

echo Creating data directory C:\data\db ...
mkdir C:\data\db 2>nul

echo Adding MongoDB to PATH...
setx PATH "%PATH%;C:\Program Files\MongoDB\Server\%VER%\bin" >nul

echo.
echo Starting MongoDB Windows service...
sc create MongoDB binPath= "\"C:\Program Files\MongoDB\Server\%VER%\bin\mongod.exe\" --service --config=\"C:\Program Files\MongoDB\Server\%VER%\bin\mongod.cfg\"" start= auto
sc start MongoDB

echo.
echo =====================================================
echo MongoDB %VER% installed successfully!
echo Service Name: MongoDB
echo Data Directory: C:\data\db
echo =====================================================
pause
exit /b



:: ====================================================
::              UNINSTALL MONGODB
:: ====================================================
:uninstall
cls
echo ===============================
echo     UNINSTALLING MONGODB
echo ===============================

echo Stopping MongoDB service...
net stop MongoDB >nul 2>&1

echo Removing MongoDB service...
sc delete MongoDB >nul 2>&1

echo Uninstalling MongoDB MSI packages...
for /f "tokens=2 delims=={}" %%i in (
    'wmic product where "name like 'MongoDB%%'" get IdentifyingNumber /value 2^>nul'
) do (
    echo Removing MongoDB MSI package %%i ...
    msiexec /x %%i /quiet
)

echo Removing MongoDB directories...
rmdir /s /q "C:\Program Files\MongoDB" 2>nul
rmdir /s /q "C:\data" 2>nul
rmdir /s /q "%USERPROFILE%\AppData\Local\MongoDB" 2>nul

echo.
echo =====================================================
echo MongoDB has been completely removed.
echo Restart PC for final cleanup.
echo =====================================================
pause
exit /b
