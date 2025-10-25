If you want to **make only the border of a video grayscale** (while keeping the rest of the video in color), you can do that in **FFmpeg** using masking and compositing filters.

Here’s a working example that turns a 20-pixel border grayscale around your video:

```bash
ffmpeg -i input.mp4 -filter_complex "
[0:v]split=2[orig][gray];
[gray]hue=s=0[gray];
[gray]crop=iw-40:ih-40:20:20[cropped_gray];
[orig][gray]overlay=0:0:enable='between(t,0,0)'[temp];
[orig][gray]blend=all_expr='if(lte(X,20)+gte(X,W-20)+lte(Y,20)+gte(Y,H-20), A*0 + B, A)'
" -c:a copy output.mp4
```

However, that line’s pretty long and confusing.
Let’s simplify it.

---

### ✅ Simpler Working Command

```bash
ffmpeg -i input.mp4 -filter_complex "
[0:v]split=2[c][g];
[g]hue=s=0[g];
[c][g]blend=all_expr='
if(lte(X,20)+gte(X,W-20)+lte(Y,20)+gte(Y,H-20),
B, A)'
" -c:a copy output.mp4
```

---

### 🔍 Explanation

* `split=2[c][g]` — duplicate the input into two streams: one for color (`c`), one for grayscale (`g`).
* `hue=s=0` — removes saturation to make grayscale.
* `blend=all_expr='...'` — pixel-by-pixel formula deciding whether to show color (`A`) or grayscale (`B`):

  * `lte(X,20)` → left border (20px)
  * `gte(X,W-20)` → right border
  * `lte(Y,20)` → top border
  * `gte(Y,H-20)` → bottom border
  * When true → use grayscale (`B`), otherwise → color (`A`).

You can change **20** to any border thickness you want (e.g. `50` for 50 pixels).

---

Would you like the **border thickness to scale automatically** based on video resolution (e.g., 5% of width/height)? I can give a version for that too.


Got it! You want to combine **deinterlacing**, **subtitle overlay**, and **grayscale border** into one `-filter_complex`.

Here’s how you can do it:

```bash
ffmpeg -i input.mp4 -filter_complex "
[0:v]yadif=1:-1[sub];
[sub]split=2[c][g];
[g]hue=s=0[g];
[c][g]blend=all_expr='if(lte(X,20)+gte(X,W-20)+lte(Y,20)+gte(Y,H-20),B,A)'[vid];
[vid][0:s:0]overlay
" -c:a copy output.mp4
```

---

### 🔹 Explanation

1. `[0:v]yadif=1:-1[sub]` — deinterlace the video.
2. `[sub]split=2[c][g]` — split the deinterlaced video into color and grayscale.
3. `[g]hue=s=0[g]` — turn one stream grayscale.
4. `blend=all_expr=...` — only make the border (20 px) grayscale.
5. `[vid][0:s:0]overlay` — overlay the subtitles on top of the video.

---

If you want, I can also make the **border size automatically scale with resolution** and put it into this exact filter chain. That way it works for any video size.

Do you want me to do that?


Good question! The **order of filters matters** because each one transforms the frames that the next sees. Let’s reason carefully:

---

### 1️⃣ Deinterlace first, then grayscale border

```text
[yadif] → [split] → [grayscale border]
```

* You deinterlace the video first (makes motion smoother, removes combing artifacts).
* Then you apply the border grayscale on fully processed frames.
* ✅ This is generally **better**, because if you grayscale first on an interlaced frame, the border might show artifacts when the interlacing is removed later.

---

### 2️⃣ Grayscale border first, then deinterlace

```text
[grayscale border] → [yadif]
```

* The grayscale border is applied on raw interlaced frames.
* Deinterlacing may blend pixels, slightly softening or bleeding the grayscale border into the color area.
* ❌ Usually not desired.

---

### ✅ Conclusion

**Always do `yadif` first, then apply the grayscale border.**
Your current chain:

```text
[0:v]yadif=1:-1[sub];[sub]split=2[c][g];...
```

is correct in terms of order.
