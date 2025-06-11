@echo off
setlocal

:: Configuration
set PACKAGE_DIR=package
set ZIP_NAME=testDeploy-package.zip
set SCRIPTS_DIR=scripts
set SERVER_DIST_DIR=scripts-dist
set FRONTEND_DIST_DIR=dist
set WINSW_URL=https://github.com/winsw/winsw/releases/download/v3.0.0/WinSW-x64.exe
set WINSW_EXE=testDeploy.exe

echo.
echo 🔧 Installing dependencies...
call npm install

echo.
echo 🏗️ Building frontend with Vite...
call npm run build

echo.
echo ⚙️ Compiling backend server...
call npm run build:scripts

echo.
echo 🧹 Pruning dev dependencies...
call npm prune --omit=dev

echo.
echo 🌐 Checking WinSW executable...

if not exist "%SCRIPTS_DIR%\%WINSW_EXE%" (
    echo 🔽 Downloading WinSW from: %WINSW_URL%
    powershell -Command "Invoke-WebRequest -Uri '%WINSW_URL%' -OutFile '%SCRIPTS_DIR%\%WINSW_EXE%'"
    if errorlevel 1 (
        echo ❌ Failed to download WinSW. Exiting.
        exit /b 1
    )
) else (
    echo ✅ WinSW executable already present: %SCRIPTS_DIR%\%WINSW_EXE%
)

echo.
echo 📦 Building Windows service deployment package...

:: Clean up old package
rmdir /s /q %PACKAGE_DIR%
del %ZIP_NAME%
mkdir %PACKAGE_DIR%

echo.
echo 📂 Copying frontend build...
xcopy /E /I /Y %FRONTEND_DIST_DIR% %PACKAGE_DIR%\dist

echo.
echo 📂 Copying backend build...
xcopy /E /I /Y %SERVER_DIST_DIR% %PACKAGE_DIR%\scripts-dist
xcopy /E /I /Y node_modules %PACKAGE_DIR%\node_modules

echo.
echo ⚙️ Copying WinSW service files...
copy %SCRIPTS_DIR%\%WINSW_EXE% %PACKAGE_DIR%\
copy %SCRIPTS_DIR%\testDeploy.xml %PACKAGE_DIR%\
copy %SCRIPTS_DIR%\install.bat %PACKAGE_DIR%\
copy %SCRIPTS_DIR%\uninstall.bat %PACKAGE_DIR%\
echo.

echo 🗜️ Creating zip archive...
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%ZIP_NAME%'"

echo.
echo ✅ Done.
echo Folder: %PACKAGE_DIR%\
echo Archive: %ZIP_NAME%

pause