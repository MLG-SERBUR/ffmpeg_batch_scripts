A repo of some scripts to quickly modify or compress videos.

Also some notes on how I create videos.

## Other notes:

### If using shotcut (or any editor that uses MLT):

#### Fix timebase

For whatever esoteric reason, the timebase in MLT (or shotcut, idk who to blame), exports with 1/15360 as its timebase instead of the standard 1/90000.

To fix, set `frame_rate_num` to `90000`, and `frame_rate_den`as the divisor of 90000 to your desired fps. I.e., `90000 / <desired fps> = frame_rate_den`

E.g. for 120 fps: `90000 / 120 = 750`, therefore set `frame_rate_den` to `750`.
```
frame_rate_num=90000
frame_rate_den=750
```

These settings (like other settings that Shotcut eagerly wants to override for whatever dum reason) don't get saved when saving a preset. You must set this in the "Other" tab in the Advanced export window.

Use `ffprobe -v 0 -of compact=p=0:nk=1 -show_entries stream=time_base -select_streams v:0 file.mp4` to verify.

Why fix timebase? So I can concatenate the resulting mp4 with other mp4s.

#### Shotcut uses low_delay in svtav1 export

This is definitely shotcut's fault. It insists on adding extra svtav1 parameters, which includes the parameter for fast delay. Since I've decided on a different approach to creating videos, I don't feel like digging up the parameter it sets. Whatever it is, you'll need to set the parameter to 2 instead of 1. And yes, this needs to be done in the "Other" Advanced export window, and yes, this gets overwritten by shotcut when saving a preset.
