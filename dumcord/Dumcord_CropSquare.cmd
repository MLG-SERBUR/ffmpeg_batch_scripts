@echo off
cd /d "%~dp0"

set "VIDEO_FILTERS=-filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0""
set "OUTPUT_SUFFIX=_crop_dumcord"

call "Dumcord.cmd" %*