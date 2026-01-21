@echo off
setlocal enabledelayedexpansion

REM --- Configuration ---
if "%TARGET_SIZE%"==""      set "TARGET_SIZE=82000000"
if "%AUDIO_BITRATE%"==""    set "AUDIO_BITRATE=96000"
if "%OVERHEAD%"==""         set "OVERHEAD=10000"
if "%AUDIO_ENCODER%"==""    set "AUDIO_ENCODER=aac"
if "%OUTPUT_EXT%"==""       set "OUTPUT_EXT=.mp4"

set "VMAF_LOG=vmaf_results.txt"

:loop
if "%~1" == "" goto end

echo.
echo =========================================================
echo Processing Source: "%~nx1"
echo =========================================================

REM --- Calculate Duration and Bitrate ---
set "seconds="
for /f "delims=" %%a in ('ffprobe -v error -select_streams v:0 -show_entries format^=duration -of csv^=p^=0 "%~1"') do (
    for /f "tokens=1 delims=." %%b in ("%%a") do set "seconds=%%b"
)
if "%seconds%"=="" set seconds=1
if %seconds% EQU 0 set seconds=1

set /a total_bitrate=TARGET_SIZE / seconds
set /a video_bitrate=total_bitrate - AUDIO_BITRATE - OVERHEAD

echo Duration: ~%seconds% seconds
echo Target Video Bitrate: %video_bitrate%
echo ---------------------------------------------------------

REM --- Define the presets to loop through ---
REM Format: "EncoderName|Preset|Suffix|ExtraParams"
for %%A in (
    "libx264|veryslow|_x264_veryslow|-x264-params open-gop=1"
    "libx265|medium|_x265_medium|-tag:v hvc1 -x265-params open-gop=1"
    "libx265|slow|_x265_slow|-tag:v hvc1 -x265-params open-gop=1"
) do (
    for /f "tokens=1,2,3,4 delims=|" %%B in ("%%~A") do (
        set "ENC=%%B"
        set "PRESET=%%C"
        set "SUFFIX=%%D"
        set "PARAMS=%%E"
        set "OUTFILE=%~n1!SUFFIX!%OUTPUT_EXT%"

        echo.
        echo [RUNNING] Encoder: !ENC! (!PRESET!) 
        echo [OUTPUT]  !OUTFILE!

        REM --- Pass 1 ---
        ffmpeg -hide_banner -y -i "%~1" ^
            -c:v !ENC! -preset !PRESET! !PARAMS! -b:v %video_bitrate% ^
            %VIDEO_FILTERS% -pass 1 -passlogfile "ffmpeg2pass" ^
            -an -f null NUL
        
        if !errorlevel! neq 0 goto error

        REM --- Pass 2 ---
        ffmpeg -hide_banner -y -i "%~1" ^
            -c:v !ENC! -preset !PRESET! !PARAMS! -b:v %video_bitrate% ^
            %VIDEO_FILTERS% -pass 2 -passlogfile "ffmpeg2pass" ^
            -movflags +faststart ^
            -c:a %AUDIO_ENCODER% -b:a %AUDIO_BITRATE% "!OUTFILE!"

        if !errorlevel! neq 0 goto error

        REM --- VMAF Comparison ---
        echo [VMAF] Comparing !OUTFILE! to source...
        echo | set /p="File: %~nx1 | Preset: !ENC!_!PRESET! | " >> "%VMAF_LOG%"
        
        REM Run ab-av1 and append only the VMAF result line to the log
        ab-av1 vmaf --reference "%~1" --distorted "!OUTFILE!" --vmaf-fps 0 --vmaf-scale none >> "%VMAF_LOG%"
        echo --------------------------------------------------------- >> "%VMAF_LOG%"

        REM Clean up temp files
        del /q "ffmpeg2pass-0.log" "ffmpeg2pass-0.mbtree" 2>nul
    )
)

shift
goto loop

:error
color 0c
echo.
echo #########################################################
echo CRITICAL ERROR DETECTED!
echo Encoding failed on: "%~nx1"
echo #########################################################
pause
exit /b 1

:end
echo.
echo =========================================================
echo All files processed. Results saved to %VMAF_LOG%
echo =========================================================
pause
exit /b 0