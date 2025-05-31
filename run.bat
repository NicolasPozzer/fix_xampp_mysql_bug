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
echo.

:: Liberar puerto 3306 (MySQL)
echo Buscando procesos usando el puerto 3306...
for /f "tokens=5" %%P in ('netstat -aon ^| findstr :3306') do (
    echo Terminando proceso en puerto 3306 con PID: %%P
    taskkill /PID %%P /F >nul 2>&1
)

call :printRed "PRIMERO se eliminaran los archivos y carpetas a reemplazar."
echo Presiona Enter para continuar con la eliminacion...
pause >nul

:: Crear carpeta si no existe
if not exist "!TARGET_PATH!" (
    mkdir "!TARGET_PATH!"
)

:: Eliminar carpetas específicas
for %%F in (
    "mysql"
    "performance_schema"
    "phpmyadmin"
    "test"
) do (
    if exist "!TARGET_PATH!\%%F" (
        echo Eliminando carpeta: %%F
        rd /s /q "!TARGET_PATH!\%%F"
    )
)

:: Eliminar archivos específicos
for %%F in (
    "aria_log.00000001"
    "aria_log_control"
    "ib_buffer_pool"
    "ib_logfile0"
    "ib_logfile1"
    "ibtmp1"
    "multi-master.info"
    "my.ini"
) do (
    if exist "!TARGET_PATH!\%%F" (
        echo Eliminando archivo: %%F
        del /f /q "!TARGET_PATH!\%%F"
    )
)

call :printGreen "Eliminacion completada."
echo.
echo Presiona Enter para mover los archivos desde 'necessary-files'...
pause >nul

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
