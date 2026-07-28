@echo off
setlocal EnableExtensions
rem Launch runtime\HabboAir.swf under AIR Debugger (adl).
rem Adapted from traxmachine/tools/debug-habboair.bat

if defined AIR_SDK_HOME (
  set "SDK=%AIR_SDK_HOME%"
) else (
  set "SDK=D:\SDKs\AIR\AIRSDK_51.2.2"
)
set "ADL=%SDK%\bin\adl.exe"
set "ROOT=%~dp0.."
set "RUNTIME=%ROOT%\runtime"
set "DESC=%~dp0HabboAir-debug-app.xml"

if not exist "%ADL%" (
  echo ERROR: adl.exe not found at:
  echo   %ADL%
  exit /b 1
)

if not exist "%RUNTIME%\HabboAir.swf" (
  echo ERROR: missing %RUNTIME%\HabboAir.swf
  echo Run tools\update-and-debug.bat or copy HabboAir_bobba.swf there first.
  exit /b 1
)

echo.
echo === Bobba Client ADL debug ===
echo SDK:       %SDK%
echo SWF:       %RUNTIME%\HabboAir.swf
echo App dir:   %RUNTIME%
echo Descriptor:%DESC%
echo.
echo Do NOT pass -nodebug ^(debug is ON by default^).
echo Close the AIR window or Ctrl+C to stop.
echo.

"%ADL%" -profile desktop "%DESC%" "%RUNTIME%"
set "ERR=%ERRORLEVEL%"
echo.
echo adl exited with code %ERR%
exit /b %ERR%
