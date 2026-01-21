@echo off
cd /d "%~dp0"

set "AUDIO_ENCODER=copy"
set "AUDIO_BITRATE=128000"
set "OUTPUT_SUFFIX=_audiocopy"

REM --- CALL MASTER SCRIPT ---
call "Dumcord.cmd" %*