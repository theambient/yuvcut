

YUVCUT
======

Tool to cut YUV 4:2:0 files both in spartial and temporal directions

Usage
-----

```
yuvcut -f <frames-to-leave> -w <new-width> -h <new-height> <input-file> <output-file>
```

Original YUV file params are deduced from `<input-file>` string which should contain `<width>x<height>` part, ie `basketballpass_416x240.yuv`.

Limitations
-----------

Currently only YUV 4:2:0 8bit format is supported.

Cutting occurs from first frame in temporal domain (ie no possibility yo skip few frames) and top left corner in spartial domain (i.e. leave only center of video sequence).
