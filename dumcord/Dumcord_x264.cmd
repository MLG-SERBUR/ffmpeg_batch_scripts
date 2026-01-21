@echo off
cd /d "%~dp0"

:loop
REM Check if we have no more files to process
if "%~1"=="" goto :end

echo.
echo =========================================================
echo Calculating Duration for: "%~nx1"
echo =========================================================

REM 1. GET DURATION
REM We use 'delims=.' to ignore milliseconds, preventing math errors.
set "cmd=ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%~1""
set "seconds="
for /f "tokens=1 delims=." %%a in ('%cmd%') do set "seconds=%%a"

REM Safety: Default to 1 second if detection fails
if "%seconds%"=="" set seconds=1
set /a seconds+=1

echo Duration: ~%seconds% seconds.

REM Math: (Target / Seconds) - Audio
set "target_size=82000000"
set "audio_bitrate=96000"
set "overhead=10000"

set /a total_bitrate=target_size / seconds
set /a video_bitrate=total_bitrate - audio_bitrate - overhead

REM 3. BITRATE SAFETY CHECK
REM If video is too long, (Total - Audio) might be negative or zero.
REM We set a hard floor of 1000 bits/s (1k) because FFmpeg cannot accept 0 or negative numbers.

if %video_bitrate% LSS 1000 (
    echo.
    echo [WARNING] Video is too long! Audio track alone is taking up almost 10MB.
    echo Setting Video Bitrate to minimum (1k). File size may slightly exceed 10MB.
    set video_bitrate=1000
)

echo Target Video Bitrate: %video_bitrate%
echo.

REM 4. PASS 1 (Analysis)
echo --- Running Pass 1 ---
ffmpeg -y -i "%~1" ^
-c:v libx264 -b:v %video_bitrate% -preset veryslow -x264-params open-gop=1 ^
-pass 1 -passlogfile "ffmpeg2pass" ^
-an -f null NUL

REM Error Check
if %errorlevel% neq 0 goto :error

REM 5. PASS 2 (Encoding)
echo.
echo --- Running Pass 2 ---
REM Outputting to Script Directory with "_2pass" suffix
ffmpeg -y -i "%~1" ^
-c:v libx264 -b:v %video_bitrate% -preset veryslow -x264-params open-gop=1 ^
-pass 2 -passlogfile "ffmpeg2pass" ^
-movflags +faststart ^
-c:a aac -b:a %audio_bitrate% "%~n1_dumcord.mp4"

REM Error Check
if %errorlevel% neq 0 goto :error

REM 6. CLEANUP LOGS
del /q "ffmpeg2pass-0.log" "ffmpeg2pass-0.mbtree"

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
del /q "ffmpeg2pass-0.log" "ffmpeg2pass-0.mbtree"
pause
exit /b 1

:end
echo.
echo =========================================================
echo All files processed successfully.
echo =========================================================
pause