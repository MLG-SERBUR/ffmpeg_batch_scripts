@echo off
cd /d "%~dp0"

REM - yadif=1:-1 : Deinterlace (Double framerate)
set "VIDEO_ENCODER=h264_nvenc -preset p1 -rc vbr -cq 20 -vf "yadif=1:-1""
set "AUDIO_ENCODER=aac -b:a 192k"
set "OUTPUT_SUFFIX=_quickdeint"
set "OUTPUT_EXT=.mp4"

call "%~dp0..\delivery.cmd" %*