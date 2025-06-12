@echo off
cd /d "%~dp0"

:: Elevate to admin if not already
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Running as administrator is required.
    echo.
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

echo Stopping and uninstalling testDeploy service...

testDeploy.exe stop
if %errorlevel% neq 0 (
    echo Warning: Failed to stop the service. It may not be running.
)

testDeploy.exe uninstall
if %errorlevel% neq 0 (
    echo Failed to uninstall the service.
    pause
    exit /b 1
)

echo ✅ Service stopped and removed.
pause