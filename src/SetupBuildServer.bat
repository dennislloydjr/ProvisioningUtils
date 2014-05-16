@echo off

:check_permissions
REM Check if Administrative Permissions are available. Otherwise quit.
REM "net session" requires admin permissions, if it errors when we call it, we don't have permission.
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrative privileges required to bootstrap the provisioning software. Please start your command shell with Administrative permissions.
	exit /b 1
)

:powershell_settings
powershell Set-ExecutionPolicy unrestricted

:set_environment
powershell -noprofile .\SetEnvironmentVariables.ps1
if %errorlevel% neq 0 (
	exit /b 1
)

powershell -noprofile .\ProvisionBuildServer.ps1