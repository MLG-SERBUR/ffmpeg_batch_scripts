@echo off
:again
set "drive=%~d0"
if not "%drive%"=="%cd:~0,1%" cd /D %drive%
cd /D %~p0
REM SET output=%~p1%~n1_Dumcord_Crop.mp4
SET output=%~nx1_deint_sub.mp4
set cmd="ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 %1 "
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET seconds=%%i
echo %seconds% seconds
set /a seconds+=1
echo %seconds% seconds
echo aaaa
echo aaaa
SET /A "totalBitrate=82000000/seconds"
SET overheadBitrate=0
SET audioBitrate=96000
SET /A "videoBitrate=totalBitrate-audioBitrate-overheadBitrate"
ffmpeg ^
	-y ^
	-i %1 ^
	-c:v libx264 ^
	-crf 20 ^
	-filter_complex "[0:v]yadif=1:-1[sub];[sub][0:s:0]overlay" ^
	-movflags +faststart ^
	-preset veryslow ^
	-x264-params open-gop=1 ^
	-b:a 192K "%output%"
if NOT ["%errorlevel%"]==["0"] goto:error
echo [92m%~n1 Done![0m

shift
if "%~1" == "" goto:end
goto:again

:error
 
echo [93mThere was an error. Please check your input file or report an issue on github.com/L0Lock/FFmpeg-bat-collection/issues.[0m
pause
exit 0

:end

echo [92mEncoding succesful. This window will close after 10 seconds.[0m
timeout /t 10