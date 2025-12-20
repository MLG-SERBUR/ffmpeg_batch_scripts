# Compression quality to size ratio

Recommended options for compressing gaming clips (usually hardware encoded and thus larger than they need to be) with minimal loss in quality

## Sorted from fastest & largest size to slowest & smallest size:

1. `-c:v libx264 -crf 19 --preset slow`
1. `-c:v libsvtav1 -crf 33 --preset 8`
1. `-c:v libsvtav1 -crf 35 --preset 6`
1. `-c:v libsvtav1 -crf 37 --preset 4`

Tested with a single 20 second Marvel Rivals clip nvenc encoded at 1080p 120fps 183Mb/s (437MB)

## At `-c:v libsvtav1 --crf 37 --preset 4`, expect about 1GB per 12 minutes

(Though it depends on how much motion is happening of course.)

Tested with a 12 minutes 4 seconds Davinci Resolve mp4 export gpu encoded at h265 1080p 68Mb/s (5.74GB)

CPU: i3-12100F: VMAF 96.52 predicted video stream size 1.01 GiB (18%) taking 2 hours (took 1hr13min for me while multitasking). I wanted to be under 1GB and encoded at crf 38, getting 822.14 MiB (14%)

---

CPU: i7-4790K

File input was 20 seconds at 437MB (~183k mbps encoded with h264 nvenc)

## Sorted test data:

libx264 medium crf 17: 171 MB
libx264 medium crf 18.5: 129 MB

Encode with: ab-av1 encode -e libx264 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 19 --preset slow
crf 19 VMAF 95.19 predicted video stream size 126.70 MiB (29%) taking 3 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 33 --preset 8
crf 33 VMAF 95.32 predicted video stream size 123.53 MiB (28%) taking 3 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 35 --preset 6
crf 35 VMAF 95.38 predicted video stream size 97.33 MiB (22%) taking 5 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 36 --preset 5
crf 36 VMAF 95.35 predicted video stream size 90.00 MiB (21%) taking 9 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 37 --preset 4
crf 37 VMAF 95.08 predicted video stream size 78.09 MiB (18%) taking 19 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 38 --preset 2
crf 38 VMAF 95.22 predicted video stream size 70.47 MiB (16%) taking 55 minutes

### Raw test data:

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 33 --preset 8
crf 33 VMAF 95.32 predicted video stream size 123.53 MiB (28%) taking 3 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 35 --preset 6
crf 35 VMAF 95.38 predicted video stream size 97.33 MiB (22%) taking 5 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 37 --preset 4
crf 37 VMAF 95.08 predicted video stream size 78.09 MiB (18%) taking 19 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 38 --preset 2
crf 38 VMAF 95.22 predicted video stream size 70.47 MiB (16%) taking 55 minutes

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 38 --preset 1
crf 38 VMAF 95.49 predicted video stream size 71.17 MiB (16%) taking 2 hours

Encode with: ab-av1 encode -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 36 --preset 5
crf 36 VMAF 95.35 predicted video stream size 90.00 MiB (21%) taking 9 minutes

Encode with: ab-av1 encode -e libx264 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 19 --preset slow
crf 19 VMAF 95.19 predicted video stream size 126.70 MiB (29%) taking 3 minutes

Encode with: ab-av1 encode -e libx264 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 19 --preset veryslow
crf 19 VMAF 95.19 predicted video stream size 118.56 MiB (27%) taking 10 minutes

Encode with: ab-av1 encode -e libx265 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 18.7
crf 18.7 VMAF 95.19 predicted video stream size 140.42 MiB (32%) taking 3 minutes

Encode with: ab-av1 encode -e libx265 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 20.9 --preset slow
crf 20.9 VMAF 95.22 predicted video stream size 109.20 MiB (25%) taking 9 minutes

Encode with: ab-av1 encode -e libx265 -i "Marvel-Win64-Shipping 2025.04.23 - 18.01.21.15.DVR.mp4" --crf 21.4 --preset veryslow
crf 21.4 VMAF 95.22 predicted video stream size 100.53 MiB (23%) taking 73 minutes

### Other tests

123 MB
> ab-av1 crf-search -i "Marvel-Win64-Shipping 2025.02.20 - 19.19.10.47.DVR.mp4" -e libx265 --preset veryslow
- crf 28 VMAF 88.29 (34%)                                                                                              )
- crf 17.2 VMAF 99.03 (153%)                                                                                           )
- crf 21.3 VMAF 97.55 (92%)                                                                                            )
- crf 23.1 VMAF 96.11 (71%)                                                                                            )
- crf 23.8 VMAF 95.36 (64%)                                                                                            )
  06:56:49 crf 24 full pass ################################################################################### (eta 0s)
Encode with: ab-av1 encode -e libx265 -i "Marvel-Win64-Shipping 2025.02.20 - 19.19.10.47.DVR.mp4" --crf 24 --preset veryslow

crf 24 VMAF 95.13 predicted video stream size 76.57 MiB (62%) taking 64 minutes