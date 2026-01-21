@echo off
cd /d "%~dp0"

REM - yadif=1:-1 : Deinterlace (Double framerate)
REM - overlay : Burn-in the first subtitle track [0:s:0]
set "VIDEO_ENCODER=libx264 -crf 20 -preset veryslow -x264-params open-gop=1 -filter_complex "[0:v]yadif=1:-1[sub];[sub][0:s:0]overlay""
set "AUDIO_ENCODER=aac -b:a 192k"
set "OUTPUT_SUFFIX=_deint_sub"
set "OUTPUT_EXT=.mp4"

call "%~dp0..\delivery.cmd" %*