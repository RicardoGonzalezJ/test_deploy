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

echo Installing testDeploy service...

testDeploy.exe install
if %errorlevel% neq 0 (
    echo Failed to install the service.
    pause
    exit /b 1
)

testDeploy.exe start
if %errorlevel% neq 0 (
    echo Failed to start the service.
    pause
    exit /b 1
)

echo Service installed and started.
pause