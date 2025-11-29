@echo off
setlocal enabledelayedexpansion

:: ============================================
::          JAVA + MAVEN DEV PACK
:: ============================================

cls
echo ===================================================
echo            JAVA DEVELOPER SETUP TOOL
echo ===================================================
echo 1. Install Java Developer Pack  (Java + Maven)
echo 2. Uninstall Java Developer Pack
echo 3. Exit
echo ===================================================
set /p choice="Enter your choice: "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
exit /b


:: ============================================
::                INSTALL PACK
:: ============================================
:install
cls
echo ================================
echo    JAVA DEVELOPER PACK INSTALL
echo ================================

:: =======================
::     JAVA INSTALL
:: =======================
echo.
echo --------------------------------
echo JAVA INSTALLATION
echo --------------------------------
echo Enter Java major version (Example: 17)
echo Leave blank to install LTS version 17
echo --------------------------------
set /p JVER="Java Version: "

if "%JVER%"=="" set JVER=17

echo.
echo Fetching Java JDK %JVER% installer...

:: Using Eclipse Temurin LTS builds (stable & reliable)
set "JAVA_URL=https://github.com/adoptium/temurin%JVER%-binaries/releases/latest/download/OpenJDK%JVER%U-jdk_x64_windows_hotspot_latest.msi"

powershell -command "try { Invoke-WebRequest '%JAVA_URL%' -OutFile 'jdk.msi' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not download Java JDK %JVER%.
    pause
    exit /b
)

echo Installing Java JDK silently...
msiexec /i jdk.msi /qn /norestart
del jdk.msi

:: Detect installation directory
set JAVA_HOME=
for /d %%D in ("C:\Program Files\Java\jdk-%JVER%*") do set JAVA_HOME=%%D
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-%JVER%*") do set JAVA_HOME=%%D

if "%JAVA_HOME%"=="" (
    echo ERROR: Could not detect installed Java directory.
    pause
    exit /b
)

echo Setting JAVA_HOME...
setx JAVA_HOME "%JAVA_HOME%" >nul
setx PATH "%PATH%;%JAVA_HOME%\bin" >nul

echo Java installed at: %JAVA_HOME%


:: =======================
::      MAVEN INSTALL
:: =======================
echo.
echo --------------------------------
echo MAVEN INSTALLATION
echo --------------------------------
echo Enter Maven Version (Example: 3.9.6)
echo Leave blank to install the LATEST version automatically
echo --------------------------------
set /p MVER="Maven Version: "

if "%MVER%"=="" (
    echo Detecting latest Maven version...
    powershell -command "(Invoke-WebRequest -Uri 'https://dlcdn.apache.org/maven/maven-3/').Links | ? { $_.href -match '^[0-9]+\.[0-9]+\.[0-9]+/$' } | Sort-Object href -Descending | Select -First 1 | %% { $_.href.TrimEnd('/') }" > maven_latest.txt

    set /p MVER=<maven_latest.txt
    del maven_latest.txt

    if "%MVER%"=="" (
        echo ERROR: Could not detect latest Maven version!
        pause
        exit /b
    )
)

set "MVN_URL=https://dlcdn.apache.org/maven/maven-3/%MVER%/binaries/apache-maven-%MVER%-bin.zip"

echo.
echo Downloading Maven %MVER% ...
powershell -command "try { Invoke-WebRequest '%MVN_URL%' -OutFile 'maven.zip' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to download Maven!
    pause
    exit /b
)

echo Installing Maven...
powershell -command "Expand-Archive 'maven.zip' -DestinationPath 'C:\Tools' -Force"
del maven.zip

set "MAVEN_HOME=C:\Tools\apache-maven-%MVER%"
setx MAVEN_HOME "%MAVEN_HOME%" >nul
setx PATH "%PATH%;%MAVEN_HOME%\bin" >nul

echo Maven installed at: %MAVEN_HOME%


:: DONE
echo.
echo ===================================================
echo      Java Developer Pack Installed Successfully!
echo ===================================================
echo JAVA_HOME  = %JAVA_HOME%
echo MAVEN_HOME = %MAVEN_HOME%
echo Restart your CMD or PC to refresh PATH.
echo ===================================================
pause
exit /b



:: ============================================
::                UNINSTALL PACK
:: ============================================
:uninstall
cls
echo ================================
echo   UNINSTALL JAVA DEV PACK
echo ================================

echo Removing Java...
for /d %%D in ("C:\Program Files\Java\jdk-*") do rmdir /s /q "%%D"
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-*") do rmdir /s /q "%%D"

echo Removing Maven...
for /d %%D in ("C:\Tools\apache-maven-*") do rmdir /s /q "%%D"

echo Removing environment variables...
reg delete "HKCU\Environment" /F /V JAVA_HOME >nul 2>&1
reg delete "HKCU\Environment" /F /V MAVEN_HOME >nul 2>&1

echo.
echo Java Developer Pack uninstalled.
echo Restart PC to refresh PATH.
pause
exit /b
