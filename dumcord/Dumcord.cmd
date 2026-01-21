@echo off
REM =========================================================
REM MASTER ENCODING LOGIC
REM Expects variables to be set by the calling script.
REM Defaults are provided below if variables are missing.
REM =========================================================

REM --- DEFAULTS ---
if "%TARGET_SIZE%"==""      set "TARGET_SIZE=82000000"
if "%AUDIO_BITRATE%"==""    set "AUDIO_BITRATE=96000"
if "%OVERHEAD%"==""         set "OVERHEAD=10000"
if "%VIDEO_ENCODER%"==""    set "VIDEO_ENCODER=libx264 -preset veryslow -x264-params open-gop=1"
if "%AUDIO_ENCODER%"==""    set "AUDIO_ENCODER=aac"
if "%OUTPUT_SUFFIX%"==""    set "OUTPUT_SUFFIX=_dumcord"
REM set "VIDEO_FILTERS=-filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0""

:loop
REM Check if we have no more files to process
if "%~1"=="" goto :end

echo.
echo =========================================================
echo Processing: "%~nx1"
echo Encoder: %VIDEO_ENCODER%
echo =========================================================

REM GET DURATION
set "cmd=ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%~1""
set "seconds="
for /f "tokens=1 delims=." %%a in ('%cmd%') do set "seconds=%%a"

REM Safety: Default to 1 second if detection fails
if "%seconds%"=="" set seconds=1
set /a seconds+=1

echo Duration: ~%seconds% seconds.

set /a total_bitrate=TARGET_SIZE / seconds
set /a video_bitrate=total_bitrate - AUDIO_BITRATE - OVERHEAD

echo Target Video Bitrate: %video_bitrate%
echo Audio Bitrate: %AUDIO_BITRATE%
if defined VIDEO_FILTERS echo Filters Applied: %VIDEO_FILTERS%
echo.

echo --- Running Pass 1 ---
ffmpeg -y -i "%~1" ^
-c:v %VIDEO_ENCODER% -b:v %video_bitrate% ^
%VIDEO_FILTERS% %VIDEO_FILTERS_P1% ^
-pass 1 -passlogfile "ffmpeg2pass" ^
-an -f null NUL

if %errorlevel% neq 0 goto :error

echo.
echo --- Running Pass 2 ---
ffmpeg -y -i "%~1" ^
-c:v %VIDEO_ENCODER% -b:v %video_bitrate% %VIDEO_PARAMS% ^
%VIDEO_FILTERS% %VIDEO_FILTERS_P2% ^
-pass 2 -passlogfile "ffmpeg2pass" ^
-movflags +faststart ^
-c:a %AUDIO_ENCODER% -b:a %AUDIO_BITRATE% "%~n1%OUTPUT_SUFFIX%.mp4"

if %errorlevel% neq 0 goto :error

del /q "ffmpeg2pass-0.log" "ffmpeg2pass-0.mbtree" 2>nul

echo [SUCCESS] "%~nx1" finished.
echo.

REM Shift to next file
shift
goto :loop

:error
color 0c
echo.
echo #########################################################
echo CRITICAL ERROR DETECTED!
echo Encoding failed on file: "%~nx1"
echo Process stopped.
echo #########################################################
del /q "ffmpeg2pass-0.log" "ffmpeg2pass-0.mbtree" 2>nul
pause
exit /b 1

:end
echo.
echo =========================================================
echo All files processed successfully.
echo =========================================================
pause
exit /b 0