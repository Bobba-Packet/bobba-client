@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Copy HabboAir_bobba.swf + brand-pack into runtime\, then launch ADL.
rem Adapted from traxmachine/tools/update-and-debug.bat

if defined AIR_SDK_HOME (
  set "SDK=%AIR_SDK_HOME%"
) else (
  set "SDK=D:\SDKs\AIR\AIRSDK_51.2.2"
)
set "ADL=%SDK%\bin\adl.exe"
set "ROOT=%~dp0.."
set "RUNTIME=%ROOT%\runtime"
set "SRC_SWF=%ROOT%\HabboAir_bobba.swf"
set "DST_SWF=%RUNTIME%\HabboAir.swf"
set "DESC=%~dp0HabboAir-debug-app.xml"
set "PACK=%ROOT%\brand-pack"
set "DBGLOG=%APPDATA%\packet.bobba.airbobba.debug\Local Store\bobba_debug.log"

echo === Update + Debug Bobba Client ===
echo Root: %ROOT%
echo.

if not exist "%ADL%" (
  echo ERROR: adl.exe not found:
  echo   %ADL%
  echo Set AIR_SDK_HOME to your AIR SDK root.
  exit /b 1
)

if not exist "%SRC_SWF%" (
  echo ERROR: missing %SRC_SWF%
  echo Run tools\inject-scripts.ps1 first.
  exit /b 1
)

if not exist "%DESC%" (
  echo ERROR: missing descriptor: %DESC%
  exit /b 1
)

if not exist "%RUNTIME%\" mkdir "%RUNTIME%" >nul 2>&1

echo [1/5] Copying HabboAir_bobba.swf -^> runtime\HabboAir.swf
copy /Y "%SRC_SWF%" "%DST_SWF%" >nul
if errorlevel 1 (
  echo ERROR: copy failed
  exit /b 1
)
for %%A in ("%DST_SWF%") do echo       OK %%~zA bytes

echo [2/5] Syncing brand-pack into runtime\
if exist "%PACK%\" (
  if exist "%RUNTIME%\bobba" rd /s /q "%RUNTIME%\bobba"
  xcopy /E /I /Y /Q "%PACK%" "%RUNTIME%\bobba\" >nul
  if not exist "%RUNTIME%\local_include" mkdir "%RUNTIME%\local_include"
  if exist "%RUNTIME%\local_include\bobba" rd /s /q "%RUNTIME%\local_include\bobba"
  xcopy /E /I /Y /Q "%PACK%" "%RUNTIME%\local_include\bobba\" >nul
  echo       OK runtime\bobba + runtime\local_include\bobba
) else (
  echo       WARN: brand-pack missing - external assets may not load
)

echo [3/5] Syncing traxmachine-pack into runtime\
set "TRAX_PACK=%ROOT%\traxmachine-pack"
if not exist "%TRAX_PACK%\catalog.json" set "TRAX_PACK=%ROOT%\..\traxmachine\traxmachine-pack"
if exist "%TRAX_PACK%\catalog.json" (
  if exist "%RUNTIME%\traxmachine" rd /s /q "%RUNTIME%\traxmachine"
  xcopy /E /I /Y /Q "%TRAX_PACK%" "%RUNTIME%\traxmachine\" >nul
  if not exist "%RUNTIME%\local_include" mkdir "%RUNTIME%\local_include"
  if exist "%RUNTIME%\local_include\traxmachine" rd /s /q "%RUNTIME%\local_include\traxmachine"
  xcopy /E /I /Y /Q "%TRAX_PACK%" "%RUNTIME%\local_include\traxmachine\" >nul
  echo       OK runtime\traxmachine + runtime\local_include\traxmachine
) else (
  echo       WARN: traxmachine-pack missing - :traxmachine assets will not load
)

echo [4/5] Syncing room placeholder SWFs into runtime\local_include\
set "CLIENT_ASSETS=%ROOT%\client-assets\local_include"
if exist "%CLIENT_ASSETS%\PlaceHolderPet.swf" (
  if not exist "%RUNTIME%\local_include" mkdir "%RUNTIME%\local_include"
  copy /Y "%CLIENT_ASSETS%\*.swf" "%RUNTIME%\local_include\" >nul
  echo       OK PlaceHolder*.swf HabboRoomContent TileCursor SelectionArrow
) else (
  echo       WARN: client-assets\local_include missing - gordon CDN 404s will break rooms
)

echo [5/5] Starting ADL debug ^(no -nodebug^)
echo       SDK:  %SDK%
echo       SWF:  %DST_SWF%
echo       Desc: %DESC%
echo       Dir:  %RUNTIME%
echo.

"%ADL%" -profile desktop "%DESC%" "%RUNTIME%"
set "ERR=%ERRORLEVEL%"

echo.
echo === adl exited %ERR% ===
if exist "%DBGLOG%" (
  echo.
  echo === bobba_debug.log ===
  type "%DBGLOG%"
  echo === end ===
)
exit /b %ERR%
