@echo off
setlocal enabledelayedexpansion

:: ===================================================
::             FULL STACK DEVELOPER PACK
:: ===================================================

cls
echo ===================================================
echo            FULL STACK DEVELOPER SETUP
echo ===================================================
echo 1. Install Full Stack Pack
echo 2. Uninstall Full Stack Pack
echo 3. Exit
echo ===================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b


:: ===================================================
::                  INSTALL PACK
:: ===================================================
:install
cls
echo ===================================================
echo             INSTALLING FULL STACK PACK
echo ===================================================



:: ===================================================
::                INSTALL NODE.JS
:: ===================================================
echo.
echo ----------------------------------------------
echo Installing Node.js (version or auto-latest)...
echo ----------------------------------------------
echo Enter Node.js Version (example: 20.10.0)
echo Leave blank to install LATEST version.
set /p NODEVER="Node.js Version: "

if "%NODEVER%"=="" (
    echo Detecting latest Node.js version...
    powershell -command "(Invoke-WebRequest 'https://nodejs.org/dist/').Links | ? { $_.href -match '^v[0-9]+\.' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.Trim('/').Replace('v','') }" > nodelatest.txt
    set /p NODEVER=<nodelatest.txt
    del nodelatest.txt
)

set "NODE_URL=https://nodejs.org/dist/v%NODEVER%/node-v%NODEVER%-x64.msi"

echo Downloading Node.js %NODEVER%...
powershell -command "try { Invoke-WebRequest '%NODE_URL%' -OutFile 'node.msi' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Node.js!
    pause
    exit /b
)

echo Installing Node.js...
msiexec /i node.msi /qn /norestart
del node.msi

echo Updating PATH for Node.js...
setx PATH "%PATH%;C:\Program Files\nodejs" >nul

echo Node.js installed successfully.



:: ===================================================
::              INSTALL JAVA JDK
:: ===================================================
echo.
echo ----------------------------------------------
echo Installing Java JDK (version or default 17)...
echo ----------------------------------------------
echo Enter Java Version (example: 17)
echo Leave blank for latest LTS (17).
set /p JVER="Java Version: "

if "%JVER%"=="" set JVER=17

set "JAVA_URL=https://github.com/adoptium/temurin%JVER%-binaries/releases/latest/download/OpenJDK%JVER%U-jdk_x64_windows_hotspot_latest.msi"

echo Downloading Java JDK %JVER%...
powershell -command "try { Invoke-WebRequest '%JAVA_URL%' -OutFile 'jdk.msi' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Java JDK!
    pause
    exit /b
)

echo Installing Java silently...
msiexec /i jdk.msi /qn /norestart
del jdk.msi

:: Detect installed location
set JAVA_HOME=
for /d %%D in ("C:\Program Files\Java\jdk-%JVER%*") do set JAVA_HOME=%%D
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-%JVER%*") do set JAVA_HOME=%%D

if "%JAVA_HOME%"=="" (
    echo ERROR: Could not detect Java installation folder.
    pause
    exit /b
)

setx JAVA_HOME "%JAVA_HOME%" >nul
setx PATH "%PATH%;%JAVA_HOME%\bin" >nul

echo Java installed: %JAVA_HOME%



:: ===================================================
::                 INSTALL MAVEN
:: ===================================================
echo.
echo ----------------------------------------------
echo Installing Maven (version or latest)...
echo ----------------------------------------------
echo Enter Maven Version (example: 3.9.6)
echo Leave blank to install latest version.
set /p MVER="Maven Version: "

if "%MVER%"=="" (
    echo Detecting latest Maven version...
    powershell -command "(Invoke-WebRequest 'https://dlcdn.apache.org/maven/maven-3/').Links | ? { $_.href -match '^[0-9]+\.[0-9]+\.[0-9]+/$' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.TrimEnd('/') }" > mavenlatest.txt
    set /p MVER=<mavenlatest.txt
    del mavenlatest.txt
)

set "MVN_URL=https://dlcdn.apache.org/maven/maven-3/%MVER%/binaries/apache-maven-%MVER%-bin.zip"

echo Downloading Maven %MVER%...
powershell -command "try { Invoke-WebRequest '%MVN_URL%' -OutFile 'maven.zip' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Maven!
    pause
    exit /b
)

echo Extracting Maven...
powershell -command "Expand-Archive 'maven.zip' 'C:\Tools' -Force"
del maven.zip

set "MAVEN_HOME=C:\Tools\apache-maven-%MVER%"
setx MAVEN_HOME "%MAVEN_HOME%" >nul
setx PATH "%PATH%;%MAVEN_HOME%\bin" >nul

echo Maven installed: %MAVEN_HOME%



:: ===================================================
::                    INSTALL GIT
:: ===================================================
echo.
echo ----------------------------------------------
echo Installing Git...
echo ----------------------------------------------

set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe"

powershell -command "try { Invoke-WebRequest '%GIT_URL%' -OutFile 'git.exe' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download Git installer!
    pause
    exit /b
)

echo Installing Git silently...
start /wait "" git.exe /VERYSILENT /NORESTART
del git.exe

echo Git installed.



:: ===================================================
::            INSTALL VISUAL STUDIO CODE
:: ===================================================
echo.
echo ----------------------------------------------
echo Installing Visual Studio Code...
echo ----------------------------------------------

set "VSCODE_URL=https://update.code.visualstudio.com/latest/win32-x64/stable"

powershell -command "try { Invoke-WebRequest '%VSCODE_URL%' -OutFile 'vscode.exe' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download VS Code!
    pause
    exit /b
)

echo Installing VS Code...
start /wait "" vscode.exe /VERYSILENT /NORESTART
del vscode.exe

echo VS Code installed.



:: ===================================================
::                     COMPLETE
:: ===================================================
echo.
echo ===================================================
echo       FULL STACK PACK INSTALLED SUCCESSFULLY!
echo ===================================================
echo Node.js       : %NODEVER%
echo Java JDK      : %JVER%
echo Maven         : %MVER%
echo Git           : Latest
echo VS Code       : Latest
echo ===================================================
echo Restart CMD or system to refresh PATH.
pause
exit /b



:: ===================================================
::                UNINSTALL PACK
:: ===================================================
:uninstall
cls
echo ===================================================
echo          UNINSTALLING FULL STACK PACK
echo ===================================================

:: Uninstall Node.js
set NODEID=
for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Node.js%%'" get IdentifyingNumber /value 2^>nul') do set NODEID=%%i
if defined NODEID msiexec /x %NODEID% /quiet

:: Uninstall Java
for /d %%D in ("C:\Program Files\Java\jdk-*","C:\Program Files\Eclipse Adoptium\jdk-*") do rmdir /s /q "%%D"
reg delete "HKCU\Environment" /F /V JAVA_HOME >nul 2>&1

:: Uninstall Maven
for /d %%D in ("C:\Tools\apache-maven-*") do rmdir /s /q "%%D"
reg delete "HKCU\Environment" /F /V MAVEN_HOME >nul 2>&1

:: Uninstall Git
set GITID=
for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Git%%'" get IdentifyingNumber /value 2^>nul') do set GITID=%%i
if defined GITID msiexec /x %GITID% /quiet

:: Uninstall VS Code
set VSCID=
for /f "tokens=2 delims=={}" %%i in ('wmic product where "name like 'Visual Studio Code%%'" get IdentifyingNumber /value 2^>nul') do set VSCID=%%i
if defined VSCID msiexec /x %VSCID% /quiet

echo.
echo Full Stack Pack has been uninstalled.
echo Restart PC to fully refresh PATH.
pause
exit /b
