@echo off
cd /d "%~dp0"

set "VIDEO_ENCODER=libsvtav1 -preset 4"
set "AUDIO_ENCODER=libopus"
set "AUDIO_BITRATE=64000"
set "OUTPUT_EXT=.webm"

REM --- CALL MASTER SCRIPT ---
call "Dumcord.cmd" %*