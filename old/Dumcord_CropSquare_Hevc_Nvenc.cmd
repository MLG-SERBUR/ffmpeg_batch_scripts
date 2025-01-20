@echo off
:again

cd /D %~p0
SET output=%~nx1_Dumcord_Crop_hevc.mp4
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
	-i %1 ^
	-c:v hevc_nvenc ^
	-b:v %videoBitrate% ^
	-pass 1 -an ^
	-preset p7 ^
	-filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0" ^
	-f mp4 NUL && \
ffmpeg ^
	-y ^
	-i %1 ^
	-c:v hevc_nvenc ^
	-b:v %videoBitrate% ^
	-pass 2 ^
	-movflags +faststart ^
	-preset p7 ^
	-filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0" ^
	-b:a %audioBitrate% "%output%"
del /q ffmpeg2pass-*.log ffmpeg2pass-*.mbtree
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