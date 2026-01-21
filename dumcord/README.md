CPU encoding always yields better quality than hardware, even with hevc_nvenc 2 pass at p7 preset. At 10MB limit, nvenc quality does not look good.

h264 is compatible with nearly everything. iOS freezes with h265 unless you set `-tag:v hvc1`.

I have it dump the result here so it doesn't get lost in my source folder.