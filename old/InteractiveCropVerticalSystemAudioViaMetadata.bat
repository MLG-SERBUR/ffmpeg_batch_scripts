@echo off
echo %CD%
echo %~dp0
cd /d %~dp0

REM For first file
REM %1
REM For multiple files
echo %*

set /P left="Side crop: "

set COUNTER=0
for %%x in (%*) do (
	echo %%x
	set /A COUNTER+=1
)
echo COUNTER = %COUNTER%

if %COUNTER% GTR 0 (
	if %COUNTER% EQU 1 (
		echo _____GET ONE FILE_____
	) else (
		echo _____GET MULTI FILES: %COUNTER% files_____
	)
	for %%x in (%*) do (
REM //////////////////// MAIN \\\\\\\\\\\\\\\\\\\\\\\\\
		REM Crop to square on decode using CUDA(?):
		REM ffmpeg.exe -loglevel info -hide_banner -hwaccel cuda -hwaccel_output_format cuda -crop 500x500x500x500 -i %%x -c:v h264_nvenc -profile:v high -level 5.1 -cq 25 -g 30 -bf 0 -c:a copy -map_metadata 0 -map 0 -map -0:a:1 "%%~nx_output_Crop.%%~xx"
		REM Crop to square (having `hwaccel_output_format cuda` negates any crop filter set for some reason):
		REM ffmpeg.exe -loglevel debug -hide_banner -hwaccel cuda -i %%x -c:v h264_nvenc -profile:v high -level 5.1 -cq 26 -g 30 -bf 0 -filter:v "crop=in_h:in_h:(in_w-out_w)/2:(in_h-out_h)/2:0" -c:a copy -map_metadata 0 -map 0 -map -0:a:1 "%%~nx_output_Crop.%%~xx"
		REM Crop to square in h264 metadata via bitstream filter (lossless crop):
		ffmpeg.exe -hide_banner -i %%x -c:v copy -bsf:v h264_metadata="crop_left=%left%:crop_right=%left%" -c:a copy -map_metadata 0 -map 0 -map -0:a:1 "%%~nx_output_Crop.%%~xx"

	)
) else (
	echo _____GET NO ONE FILES_____
)

pause