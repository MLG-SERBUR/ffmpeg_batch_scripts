@echo off
:again

cd /D %~p0
SET output=%~p1%~n1.stripped.mp4
echo aaaa
echo aaaa
ffmpeg ^
	-i %1 ^
	-map_metadata 0 -movflags use_metadata_tags ^
	-c copy ^
	-map 0 -map -0:a:1 "%output%"
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