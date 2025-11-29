@echo off
setlocal enabledelayedexpansion

:: ============================================
::           REACT DEVELOPER PACK
:: ============================================

cls
echo ===================================================
echo               REACT DEVELOPER PACK
echo ===================================================
echo 1. Install React Dev Pack
echo 2. Uninstall React Dev Pack
echo 3. Exit
echo ===================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b



:: ============================================
::                 INSTALL PACK
:: ============================================
:install
cls
echo ================================
echo     REACT DEV PACK INSTALLER
echo ================================



:: ============================================
::         INSTALL NODE.JS (LATEST/USER VERSION)
:: ============================================
echo.
echo ---------------------------------------
echo INSTALLING NODE.JS
echo ---------------------------------------
echo Enter Node.js Version (example: 20.10.0)
echo Leave blank for LATEST version
echo ---------------------------------------
set /p NODEVER="Node.js Version: "

if "%NODEVER%"=="" (
    echo Detecting latest Node.js version...
    powershell -command "(Invoke-WebRequest -Uri 'https://nodejs.org/dist/').Links | ? { $_.href -match '^v[0-9]+\.' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.Trim('/').Replace('v','') }" > nodelatest.txt

    set /p NODEVER=<nodelatest.txt
    del nodelatest.txt

    if "%NODEVER%"=="" (
        echo ERROR: Could not detect latest Node version!
        pause
        exit /b
    )
)

set "NODE_URL=https://nodejs.org/dist/v%NODEVER%/node-v%NODEVER%-x64.msi"

echo Downloading Node.js %NODEVER% ...
powershell -command "try { Invoke-WebRequest '%NODE_URL%' -OutFile 'node.msi' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Node.js download failed.
    pause
    exit /b
)

echo Installing Node.js silently...
msiexec /i node.msi /qn /norestart
del node.msi

echo Updating PATH for Node.js...
setx PATH "%PATH%;C:\Program Files\nodejs" >nul

echo Node.js installed successfully.


:: ============================================
::         INSTALL VISUAL STUDIO CODE
:: ============================================
echo.
echo ---------------------------------------
echo INSTALLING VISUAL STUDIO CODE
echo ---------------------------------------

set "VSCODE_URL=https://update.code.visualstudio.com/latest/win32-x64/stable"

echo Downloading VS Code...
powershell -command "try { Invoke-WebRequest '%VSCODE_URL%' -OutFile 'vscode.exe' -ErrorAction Stop } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download VS Code!
    pause
    exit /b
)

echo Installing VS Code silently...
start /wait "" vscode.exe /VERYSILENT /NORESTART
del vscode.exe

echo VS Code installed successfully.



:: ============================================
::         INSTALL REACT DEV TOOLS
:: ============================================
echo.
echo ---------------------------------------
echo INSTALLING REACT DEVELOPMENT TOOLS
echo ---------------------------------------

echo Updating npm version...
npm install -g npm

echo Installing create-react-app support...
npm install -g create-react-app

echo React developer tools installed.



:: ============================================
::                 FINISH
:: ============================================
echo.
echo ===================================================
echo        React Developer Pack Installed!
echo ===================================================
echo - Node.js %NODEVER%
echo - Visual Studio Code
echo - React CLI (npm, npx, CRA)
echo Restart terminal to refresh PATH.
echo ===================================================
pause
exit /b



:: ============================================
::             UNINSTALL PACK
:: ============================================
:uninstall
cls
echo ================================
echo   UNINSTALL REACT DEV PACK
echo ================================


:: ----- Uninstall React tools -----
echo Removing global create-react-app...
npm uninstall -g create-react-app 2>nul


:: ----- Uninstall Node.js -----
echo Searching for Node.js MSI package...
set NODEID=

for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Node.js%%'" get IdentifyingNumber /value 2^>nul') do (
    set NODEID=%%i
)

if not "%NODEID%"=="" (
    echo Uninstalling Node.js...
    msiexec /x %NODEID% /quiet
) else (
    echo Node.js not found in MSI database.
)


:: ----- Uninstall VS Code -----
echo Searching for Visual Studio Code...
set VSCODEID=

for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Visual Studio Code%%'" get IdentifyingNumber /value 2^>nul') do (
    set VSCODEID=%%i
)

if not "%VSCODEID%"=="" (
    echo Uninstalling VS Code...
    msiexec /x %VSCODEID% /quiet
) else (
    echo VS Code uninstall entry not found.
)


echo.
echo React Developer Pack uninstalled.
echo Restart recommended to refresh PATH.
pause
exit /b
