@echo off
cd /d "%~dp0"

REM Crops to portrait in h264 metadata via bitstream filter (lossless crop).

REM Other attempts to investigate in future:

REM Crop to square on decode using CUDA with `h264_cuvid` decoder.
REM This decoder is slightly older than the modern nvdec implementation but is the only one that supports hardware-level cropping during the decode stage.
REM Use `hevc_cuvid` for HEVC.
REM ffmpeg.exe -loglevel info -hide_banner -c:v h264_cuvid -crop 500x500x500x500 -i %%x -c:v h264_nvenc -profile:v high -level 5.1 -cq 25 -g 30 -bf 0 -c:a copy -map_metadata 0 -map 0 -map -0:a:1 "%%~nx_output_Crop.%%~xx"

REM Decode in GPU, Crop to square in CPU.
REM Setting `hwaccel_output_format cuda` will keep frames in GPU thus preventing CPU crop filter from being applied
REM `hwdownload,format=nv12` before the crop and `hwupload` after if you want to manually tell ffmpeg to move frames between GPU and CPU, or just omit `hwaccel_output_format`.
REM `hwaccel cuda` is a generic hardware acceleration switch.
REM ffmpeg.exe -loglevel debug -hide_banner -hwaccel cuda -i %%x -c:v h264_nvenc -profile:v high -level 5.1 -cq 26 -g 30 -bf 0 -filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0" -c:a copy -map_metadata 0 -map 0 -map -0:a:1 "%%~nx_output_Crop.%%~xx"


:loop
REM Check if we have no more files to process
if "%~1"=="" goto :end

echo.
echo =========================================================
echo Analyzing: "%~nx1"
echo =========================================================

REM ffprobe gets comma-separated values: e.g., "h264,1920,1080"
set "CODEC="
set "WIDTH="
set "HEIGHT="
set "cmd=ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of csv=p=0 "%~1""

for /f "tokens=1,2,3 delims=," %%a in ('%cmd%') do (
    set "CODEC=%%a"
    set "WIDTH=%%b"
    set "HEIGHT=%%c"
)

if "%CODEC%"=="" (
    echo.
    echo [FAILURE] FFprobe could not detect video stream info.
    goto :error
)

if %WIDTH% leq %HEIGHT% (
    echo.
    echo [FAILURE] Input video is %WIDTH%x%HEIGHT% ^(Not Landscape^).
    goto :error
)

REM 2. DETERMINE CROP VALUES (Math for 9:16 Portrait)
REM Target Width = (Height * 9) / 16
REM Example: 1080p Height -> 607.5 Width (Batch rounds down to 607)
REM Crop = (Current Width - Target Width) / 2
set /a "TARGET_WIDTH=(HEIGHT * 9) / 16"
set /a "CROP_VAL=(WIDTH - TARGET_WIDTH) / 2"

echo Resolution: %WIDTH%x%HEIGHT% (%CODEC%)
echo Target 9:16 Width: ~%TARGET_WIDTH% px
echo Calculated Crop: %CROP_VAL% px (Left/Right)

set "BSF_FILTER="
if "%CODEC%"=="h264" set "BSF_FILTER=h264_metadata"
if "%CODEC%"=="hevc" set "BSF_FILTER=hevc_metadata"

if "%BSF_FILTER%"=="" (
    echo.
    echo [FAILURE] Codec "%CODEC%" is not supported for metadata cropping.
    echo Only H.264 and HEVC are supported.
    goto :error
)

ffmpeg -hide_banner -y -i "%~1" -map_metadata 0 ^
-c:v copy -bsf:v %BSF_FILTER%="crop_left=%CROP_VAL%:crop_right=%CROP_VAL%" ^
-c:a copy ^
"%~dp1%~n1_lossless_portrait%~x1"

if %errorlevel% neq 0 goto :error

echo [SUCCESS] "%~nx1" finished.

REM Shift to the next file
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