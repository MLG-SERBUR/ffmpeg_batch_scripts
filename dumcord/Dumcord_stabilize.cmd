@echo off
cd /d "%~dp0"

REM Pass 1 analyzes the shaky movement
set "VIDEO_FILTERS_P1=-vf vidstabdetect=shakiness=10"
REM Pass 2 applies the smoothness
set "VIDEO_FILTERS_P2=-vf vidstabtransform"
set "OUTPUT_SUFFIX=_stabilized"

call "Dumcord.cmd" %*