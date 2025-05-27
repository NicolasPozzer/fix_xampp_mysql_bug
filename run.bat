@echo off
:: Verificar si se esta ejecutando como administrador
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

setlocal enabledelayedexpansion

:: Carpeta de origen
set "SOURCE_DIR=%~dp0necessary-files"

if not exist "%SOURCE_DIR%" (
    call :printRed "La carpeta 'necessary-files' no existe en la misma carpeta que este script."
    pause
    exit /b
)

:: Ruta por defecto
set "DEFAULT_PATH=C:\xampp\mysql\data"

echo Ruta por defecto para mover los archivos: %DEFAULT_PATH%
set /p USER_PATH=Deseas usar esta ruta? (Presiona Enter para aceptar o escribe una ruta personalizada): 

if "%USER_PATH%"=="" (
    set "TARGET_PATH=%DEFAULT_PATH%"
) else (
    set "TARGET_PATH=%USER_PATH%"
)

echo Archivos seran movidos a: !TARGET_PATH!
set /p CONFIRM=Deseas continuar? (s/n): 
if /i not "!CONFIRM!"=="s" (
    call :printRed "Operacion cancelada por el usuario."
    pause
    exit /b
)

:: Crear carpeta si no existe
if not exist "!TARGET_PATH!" (
    mkdir "!TARGET_PATH!"
)

echo Moviendo archivos...
xcopy /E /Y /I "%SOURCE_DIR%\*" "!TARGET_PATH!\" >nul

if %errorlevel% equ 0 (
    call :printGreen "Archivos movidos y reemplazados con exito."
) else (
    call :printRed "Hubo un error al mover los archivos."
)

pause
exit /b

:: -------- FUNCIONES DE COLOR --------

:printGreen
powershell -Command "Write-Host '%~1' -ForegroundColor Green"
exit /b

:printRed
powershell -Command "Write-Host '%~1' -ForegroundColor Red"
exit /b
