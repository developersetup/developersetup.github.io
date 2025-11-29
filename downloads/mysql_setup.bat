@echo off
setlocal enabledelayedexpansion

:: ============================================
::                MYSQL SETUP TOOL
:: ============================================

cls
echo ====================================================
echo                 MYSQL INSTALLER TOOL
echo ====================================================
echo 1. Install MySQL
echo 2. Uninstall MySQL
echo 3. Exit
echo ====================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ====================================================
::               INSTALL MYSQL
:: ====================================================
:install
cls
echo ===============================
echo        INSTALLING MYSQL
echo ===============================
echo Enter MySQL Installer Version (Example: 8.0.36)
echo Leave blank to use LATEST recommended version.
echo.
set /p VER="Version: "

if "%VER%"=="" (
    echo Using recommended latest version: 8.0.36
    set VER=8.0.36
)

set "MYSQL_URL=https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-%VER%.0.msi"

echo Download URL:
echo %MYSQL_URL%
echo.

echo Downloading MySQL Installer...
powershell -command "try { Invoke-WebRequest '%MYSQL_URL%' -OutFile 'mysql.msi' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to download MySQL Installer.
    echo Check internet or version number.
    pause
    exit /b
)

echo Running MySQL Installer...
echo -------------------------------------------
echo NOTE: MySQL Installer GUI will open now.
echo You must manually select:
echo    - MySQL Server
echo    - MySQL Workbench (optional)
echo Then click INSTALL.
echo -------------------------------------------
echo.

start /wait "" msiexec /i mysql.msi
del mysql.msi

echo.
echo ============================================
echo MySQL Installer completed (if no errors).
echo ============================================
pause
exit /b



:: ====================================================
::              UNINSTALL MYSQL
:: ====================================================
:uninstall
cls
echo ===============================
echo       UNINSTALLING MYSQL
echo ===============================

echo Stopping MySQL service if running...
net stop MySQL >nul 2>&1

echo Finding installed MySQL components...

:: Uninstall all MSI-installed MySQL products
for /f "tokens=2 delims=={}" %%i in (
    'wmic product where "name like 'MySQL%%'" get IdentifyingNumber /value 2^>nul'
) do (
    echo Removing MSI package %%i ...
    msiexec /x %%i /quiet
)

echo.
echo Removing default MySQL directories...
rmdir /s /q "C:\ProgramData\MySQL" 2>nul
rmdir /s /q "C:\Program Files\MySQL" 2>nul
rmdir /s /q "%USERPROFILE%\AppData\Roaming\MySQL" 2>nul

echo.
echo ============================================
echo MySQL has been uninstalled completely.
echo A restart is recommended.
echo ============================================
pause
exit /b
