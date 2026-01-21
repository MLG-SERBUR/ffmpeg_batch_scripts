@echo off
cd /d "%~dp0"

REM Remove separated audio tracks
set "AUDIO_ENCODER=copy -map 0 -map -0:a:1 -map -0:a:2 -map -0:a:3"
set "AUDIO_BITRATE=196000"
set "OUTPUT_SUFFIX=_Dumcord_Medal"

call "Dumcord.cmd" %*