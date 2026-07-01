@echo off
setlocal

set "APP_DIR="
for /d %%D in ("%~dp0*") do (
  if exist "%%~fD\package.json" set "APP_DIR=%%~fD"
)

if "%APP_DIR%"=="" (
  echo Cannot find pet source folder under:
  echo %~dp0
  pause
  exit /b 1
)

set "ELECTRON_EXE=%APP_DIR%\node_modules\electron\dist\electron.exe"

if not exist "%ELECTRON_EXE%" (
  echo Installing desktop pet dependencies...
  pushd "%APP_DIR%"
  call npm.cmd install
  if errorlevel 1 (
    echo.
    echo Failed to install dependencies.
    pause
    popd
    exit /b 1
  )
  popd
)

start "" "%ELECTRON_EXE%" "%APP_DIR%"
exit /b 0
