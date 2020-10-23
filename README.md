## Static Video Gallery Generator (BASH builtin) ![repo size](https://img.shields.io/github/size/rojenzaman/video-gallery-generator_bash/video-gallery-generator.sh) ![license](https://img.shields.io/github/license/rojenzaman/video-gallery-generator_bash) ![lang](https://img.shields.io/github/languages/top/rojenzaman/video-gallery-generator_bash)

Demo web site available on https://rojenzaman.github.io/video-gallery/
### Install

    git clone https://github.com/rojenzaman/video-gallery-generator_bash.git

### Usage

Go to your videos directory and type this commands:

    ./video-gallery-generator -t "Title" [-d "out-dirname"]
    
### RULES
- The videos are must be MP4
- The subtitle files are must be VTT
- Subtitle file names are must be same name with their videos file.
- Videos must have a title and artist metadata in order to be displayed as a title on the html page, if not they called by file names.

### Screenshots

<img src="https://raw.githubusercontent.com/rojenzaman/rojenzaman.github.io/main/uploads/ss-1.jpeg" width="100%" alt="ss-1">
<img src="https://raw.githubusercontent.com/rojenzaman/rojenzaman.github.io/main/uploads/ss-2.jpeg" width="100%" alt="ss-2">

<br>

powered by [GNU Bash](https://www.gnu.org/software/bash/), [Plyr](https://plyr.io/), [FFmpeg](https://ffmpeg.org/), [exiftool](https://exiftool.org/) and [ImageMagick](https://imagemagick.org/index.php)

<br>

> **GNU General Public License v3.0** , 2020
