# Dumcord 10MB compression scripts

CPU encoding always yields better quality than hardware, even with hevc_nvenc 2 pass at p7 preset. At 10MB limit, nvenc quality does not look good.

I have it dump the output here so it doesn't get lost in my source folder.

## Uses libx265 medium by default

I use h265/HEVC with libx265 on medium preset as this is faster and better quality than h264 on veryslow preset. Libx265 on slow preset is signficantly slower.

- libx264 | Preset: veryslow | Time: 153s | VMAF: 43.471596 
- libx265 | Preset: medium | Time: 89s | VMAF: 52.94434 
- libx265 | Preset: slow | Time: 235s | VMAF: 59.50313 