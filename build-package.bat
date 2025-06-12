@echo off
setlocal enabledelayedexpansion

:: Configuration
set BUILD_TEMP=build-temp
set PACKAGE_DIR=package
set ZIP_NAME=testDeploy-package.zip
set SCRIPTS_DIR=scripts
set SERVER_DIST_DIR=scripts-dist
set FRONTEND_DIST_DIR=dist
set WINSW_URL=https://github.com/winsw/winsw/releases/latest/download/WinSW-x64.exe
set WINSW_EXE=testDeploy.exe

echo.
echo Cleaning up previous build folder...
rmdir /s /q "%BUILD_TEMP%" 2>nul
mkdir "%BUILD_TEMP%"
echo.

:: Copy all project files to build-temp except node_modules
echo Copying project files to isolated temp dir...
robocopy . "%BUILD_TEMP%" /E /XD node_modules .git %BUILD_TEMP% /NFL /NDL /NJH /NJS >nul
if errorlevel 8 (
    echo robocopy failed
    exit /b 1
)
echo Copied to %BUILD_TEMP%
echo.

:: Change to temp directory
pushd "%BUILD_TEMP%"

echo.
echo Installing dependencies...
call npm install

echo.
echo Building frontend with Vite...
call npm run build

echo.
echo Compiling backend server...
call npm run build:scripts

echo.
echo Removing dev dependencies...
:: More reliable alternative to avoid EPERM errors:
rmdir /s /q node_modules
call npm install --omit=dev
if errorlevel 1 (
    echo Failed to install prod dependencies
    exit /b 1
)

echo.
echo Checking WinSW executable...
if not exist "%SCRIPTS_DIR%\%WINSW_EXE%" (
    echo Downloading WinSW from: %WINSW_URL%
    curl --ssl-no-revoke -L -o "%SCRIPTS_DIR%\%WINSW_EXE%" "%WINSW_URL%"
    if errorlevel 1 (
        echo Failed to download WinSW. Exiting.
        exit /b 1
    )
) else (
    echo WinSW executable already present: %SCRIPTS_DIR%\%WINSW_EXE%
)
echo.

echo Building Windows service deployment package...

:: Clean up old package
rmdir /s /q "%PACKAGE_DIR%" 2>nul
del "%ZIP_NAME%" 2>nul 
mkdir "%PACKAGE_DIR%"

echo.
echo Copying frontend build...
xcopy /E /I /Y "%FRONTEND_DIST_DIR%" "%PACKAGE_DIR%\dist" >nul

echo Copying server files...
xcopy /E /I /Y "%SERVER_DIST_DIR%" "%PACKAGE_DIR%\scripts-dist" >nul
xcopy /E /I /Y node_modules "%PACKAGE_DIR%\node_modules" >nul

echo Copying WinSW service files...
copy "%SCRIPTS_DIR%\%WINSW_EXE%" "%PACKAGE_DIR%\" >nul
copy "%SCRIPTS_DIR%\testDeploy.xml" "%PACKAGE_DIR%\" >nul
copy "%SCRIPTS_DIR%\install.bat" "%PACKAGE_DIR%\" >nul
copy "%SCRIPTS_DIR%\uninstall.bat" "%PACKAGE_DIR%\" >nul
echo.

:: Go back to root
popd

echo Moving final output outside build-temp...
move "%BUILD_TEMP%\%PACKAGE_DIR%" "%PACKAGE_DIR%" >nul
echo.

echo Creating zip archive...
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%ZIP_NAME%'" 
echo.

:: Clean up temp folder
rmdir /s /q "%BUILD_TEMP%" 2>nul

echo Done.
echo Folder: %PACKAGE_DIR%\
echo Archive: %ZIP_NAME%

pause