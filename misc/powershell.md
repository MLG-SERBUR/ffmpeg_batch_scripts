- Loop through each .mp4 file in a directory
- encode with libx264
- set `faststart` and preserve metadata
- append `_x264.mp4` to output (basename)

```powershell
Get-ChildItem -Filter "*.mp4" | ForEach-Object { ffmpeg -i $_.FullName -movflags use_metadata_tags -movflags faststart -map_metadata 0 -c:v libx264 -crf 17 -c:a copy (Join-Path $_.Directory ($_.BaseName + "_x264.mp4")) }
```
