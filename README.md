## Static Video Gallery Generator (BASH builtin) ![repo size](https://img.shields.io/github/size/rojenzaman/video-gallery-generator_bash/video-gallery-generator.sh) ![license](https://img.shields.io/github/license/rojenzaman/video-gallery-generator_bash) ![lang](https://img.shields.io/github/languages/top/rojenzaman/video-gallery-generator_bash)

Demo web site available on https://rojenzaman.github.io/video-gallery/

### Usage

```
Usage: video-gallery-generator.sh [-t <title>] [-d <thumbdir>] [-m] [-e] [-s] [-q] [-h]:
    [-t <title>]     sets the title (default: Video Gallery)
    [-d <thumbdir>]     sets the thumbdir (default: video)
    [-m]         use tmpfs for html generation (default: /dev/shm/vgg-index.html)
    [-e]         skip print exif data
    [-s]         skip thumbnail generation
    [-q]         skip author and title generation
    [-h]         displays help (this message)
```

### RULES

- Videos must be MP4.
- Subtitle files must be VTT.
- Subtitle filenames must be the same as video files.
- Videos must have a title and artist metadata to be displayed as a title in the html page if not called by their filename.

### Screenshots

<img src="https://raw.githubusercontent.com/rojenzaman/rojenzaman.github.io/main/uploads/ss-1.jpeg" width="100%" alt="ss-1">
<img src="https://raw.githubusercontent.com/rojenzaman/rojenzaman.github.io/main/uploads/ss-2.jpeg" width="100%" alt="ss-2">

<br>

powered by [GNU Bash](https://www.gnu.org/software/bash/), [pp](https://adi.onl/pp.html), [Plyr](https://plyr.io/), [FFmpeg](https://ffmpeg.org/), [exiftool](https://exiftool.org/) and [ImageMagick](https://imagemagick.org/index.php)

<br>

> **GNU General Public License v3.0** , 2020
