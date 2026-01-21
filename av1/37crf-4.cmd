@echo off
cd /d "%~dp0"

:loop
REM Check if we have no more files to process
if "%~1"=="" goto :end

echo.
echo =========================================================
echo Processing: "%~nx1"
echo =========================================================

REM COMMAND EXPLANATION:
REM "%~n1" gives just the filename (no extension)
REM "%~x1" gives just the extension (.mp4, .mkv, etc)
REM use "%~dp1%~n1_av1%~x1" to save in the same directory as the source file
REM use "%~n1_av1%~x1" to save in script directory

ffmpeg.exe -hide_banner -y -i "%~1" -map_metadata 0 ^
-c:v libsvtav1 -crf 37 -preset 4 ^
-movflags +faststart ^
-c:a copy "%~dp1%~n1_av1%~x1"

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
echo The encoding failed on file: "%~nx1"
echo Process stopped.
echo #########################################################
pause
exit /b 1

:end
echo.
echo =========================================================
echo All files processed successfully.
echo =========================================================
pause