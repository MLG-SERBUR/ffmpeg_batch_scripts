@echo off
cd /d "%~dp0"

REM - yadif=1:-1 : Deinterlace (Double framerate)
set "VIDEO_ENCODER=libx264 -crf 20 -preset veryslow -x264-params open-gop=1 -vf "yadif=1:-1""
set "AUDIO_ENCODER=aac -b:a 192k"
set "OUTPUT_SUFFIX=_deint_sub"
set "OUTPUT_EXT=.mp4"

call "%~dp0..\delivery.cmd" %*