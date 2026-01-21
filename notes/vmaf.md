# Notes about VMAF

## ab-av1 adds additional parameters to VMAF by default

I'm not sure why it does this but it automatically scales and sets fps to 25. I've found this to cause more issues than it solves.

```
--vmaf-fps 0 --vmaf-scale none
```

This appears to give an equivalent result to

```
ffmpeg -i distorted.mp4 -i reference.mp4 -lavfi libvmaf -f null -
```

ab-av1 vmaf works a lot faster (and uses more CPU) than the ffmpeg command so I'm not sure how it's doing that.

### defaults

According to AI.

ffmpeg Uses vmaf_v0.6.1 by default, netflix standard. Equivalent `-lavfi libvmaf=model_path=vmaf_v0.6.1.pkl`

ab-av1 switches between a 1K and 4K model depending on video resolution


## If you desire highly detailed output of ffmpeg VMAF

set `-lavfi libvmaf=log_path=output.json` or similar