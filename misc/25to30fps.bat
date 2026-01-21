@echo off
cd /d "%~dp0"

:loop
REM Check if we have no more files to process
if "%~1"=="" goto :end

echo.
echo =========================================================
echo Processing: "%~nx1"
echo =========================================================

REM -itsscale 0.83333333 : Rescales timestamps (1 / 0.833 = 1.2x speed approx)
REM -movflags use_metadata_tags : Allows arbitrary tags in output

ffmpeg.exe -hide_banner -itsscale 0.83333333 -i "%~1" ^
-map_metadata 0 -movflags use_metadata_tags ^
-c copy -map 0 ^
"%~dp1%~n1_output_copy%~x1"

if %errorlevel% neq 0 goto :error

echo [SUCCESS] "%~nx1" finished.

REM Shift moves to the next file in the drag-and-drop list
shift
goto :loop

:error
color 0c
echo.
echo #########################################################
echo CRITICAL ERROR DETECTED!
echo Process stopped on file: "%~nx1"
echo #########################################################
pause
exit /b 1

:end
echo.
echo =========================================================
echo All files processed successfully.
echo =========================================================
pause
exit /b 0