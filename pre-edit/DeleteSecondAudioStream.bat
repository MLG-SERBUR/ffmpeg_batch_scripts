@echo off
echo %CD%
echo %~dp0
cd /d %~dp0

REM For first file
REM %1
REM For multiple files
echo %*

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
		ffmpeg.exe -hide_banner -i %%x -map_metadata 0 -movflags use_metadata_tags -c copy -map 0 -map -0:a:1 "%%~nx_output_stripped.%%~xx"

	)
) else (
	echo _____GET NO ONE FILES_____
)

pause