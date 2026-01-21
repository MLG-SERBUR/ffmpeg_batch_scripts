@echo off
setlocal EnableDelayedExpansion

REM ================= USER CONFIG =================
if "%TARGET_SIZE%"==""   set "TARGET_SIZE=82000000"
if "%AUDIO_BITRATE%"=="" set "AUDIO_BITRATE=96000"
if "%OVERHEAD%"==""      set "OVERHEAD=10000"
if "%AUDIO_ENCODER%"=="" set "AUDIO_ENCODER=aac"
if "%OUTPUT_EXT%"==""    set "OUTPUT_EXT=.mp4"

set "MOV_FLAGS="
if /i "%OUTPUT_EXT%"==".mp4" set "MOV_FLAGS=-movflags +faststart"

REM Optional filters
REM set "VIDEO_FILTERS=-vf scale=1280:-2"

REM ================= ENCODER MATRIX =================
set ENCODERS[0]=x264_veryslow|libx264 -preset veryslow -x264-params open-gop=1
set ENCODERS[1]=x265_medium|libx265 -preset medium -tag:v hvc1 -x265-params open-gop=1
set ENCODERS[2]=x265_slow|libx265 -preset slow -tag:v hvc1 -x265-params open-gop=1
set ENCODERS[3]=x265_veryslow|libx265 -preset veryslow -tag:v hvc1 -x265-params open-gop=1
set ENCODER_COUNT=4

REM ================= INPUT LOOP =================
:loop
if "%~1"=="" goto :end

set "INPUT=%~1"
set "BASENAME=%~n1"
set "VMAF_SUMMARY=%BASENAME%_vmaf_results.txt"

echo.
echo =========================================================
echo Processing input: "%~nx1"
echo =========================================================

REM ---- get duration ----
for /f "tokens=1 delims=." %%a in (
  'ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%INPUT%"'
) do set seconds=%%a

if not defined seconds set seconds=1
set /a seconds+=1

set /a total_bitrate=TARGET_SIZE / seconds
set /a video_bitrate=total_bitrate - AUDIO_BITRATE - OVERHEAD

echo Duration: %seconds%s
echo Target video bitrate: %video_bitrate%
echo.

echo VMAF RESULTS FOR %~nx1 > "%VMAF_SUMMARY%"
echo ========================================== >> "%VMAF_SUMMARY%"
echo. >> "%VMAF_SUMMARY%"

REM ================= ENCODE LOOP =================
for /L %%i in (0,1,%ENCODER_COUNT%-1) do (

  for /f "tokens=1,2 delims=|" %%A in ("!ENCODERS[%%i]!") do (
    set "LABEL=%%A"
    set "VIDEO_ENCODER=%%B"
  )

  set "PASSLOG=ffmpeg2pass_!LABEL!"
  set "OUTPUT=%BASENAME%_!LABEL!%OUTPUT_EXT%"
  set "VMAF_JSON=%BASENAME%_!LABEL!_vmaf.json"

  echo ---------------------------------------------------------
  echo Encoder: !LABEL!
  echo Output : !OUTPUT!
  echo ---------------------------------------------------------

  REM --- Pass 1 ---
  ffmpeg -y -i "%INPUT%" ^
    -c:v !VIDEO_ENCODER! -b:v %video_bitrate% ^
    %VIDEO_FILTERS% ^
    -pass 1 -passlogfile "!PASSLOG!" ^
    -an -f null NUL

  if errorlevel 1 (
      echo ERROR: Pass 1 failed for !LABEL! on %~nx1
      pause
      goto :error
  )

  REM --- Pass 2 ---
  ffmpeg -y -i "%INPUT%" ^
    -c:v !VIDEO_ENCODER! -b:v %video_bitrate% ^
    %VIDEO_FILTERS% ^
    -pass 2 -passlogfile "!PASSLOG!" ^
    %MOV_FLAGS% ^
    -c:a %AUDIO_ENCODER% -b:a %AUDIO_BITRATE% "!OUTPUT!"

  if errorlevel 1 (
      echo ERROR: Pass 2 failed for !LABEL! on %~nx1
      pause
      goto :error
  )

  del /q "!PASSLOG!-0.log" "!PASSLOG!-0.mbtree" 2>nul

  REM --- VMAF ---
  echo --- Running VMAF for !LABEL! ---
  ab-av1 vmaf ^
    --reference "%INPUT%" ^
    --distorted "!OUTPUT!" ^
    --model vmaf_v0.6.1 ^
    --subsample 1 ^
    --vmaf-scale none ^
    --vmaf-fps 0 ^
    --json "!VMAF_JSON!" >> "%VMAF_SUMMARY%"

  if errorlevel 1 (
      echo ERROR: VMAF failed for !LABEL! on %~nx1
      pause
      goto :error
  )

  echo. >> "%VMAF_SUMMARY%"
  echo [OK] !LABEL! finished.
  echo.
)

shift
goto :loop

REM ================= ERROR =================
:error
echo.
echo #########################################################
echo CRITICAL ERROR ON FILE: "%~nx1"
echo Check above messages for details
echo #########################################################
pause
exit /b 1

REM ================= DONE =================
:end
echo.
echo =========================================================
echo ALL FILES, ENCODES, AND VMAF TESTS COMPLETE
echo =========================================================
pause
exit /b 0
