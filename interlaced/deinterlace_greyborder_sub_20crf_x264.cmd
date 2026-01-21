@echo off
cd /d "%~dp0"

REM - yadif=1:-1 : Deinterlace (Double framerate)
REM - split/hue/blend : Create Grey Borders
REM - overlay : Burn-in the first subtitle track [0:s:0]
set "VIDEO_ENCODER=libx264 -crf 20 -preset veryslow -x264-params open-gop=1 -filter_complex "[0:v]yadif=1:-1[sub];[sub]split=2[c][g];[g]hue=s=0[g];[c][g]blend=all_expr='if(lte(X,20)+gte(X,W-20)+lte(Y,20)+gte(Y,H-20),B,A)'[vid];[vid][0:s:0]overlay""
set "AUDIO_ENCODER=aac -b:a 192k"
set "OUTPUT_SUFFIX=_deint_sub_greyborder"
set "OUTPUT_EXT=.mp4"

call "%~dp0..\delivery.cmd" %*