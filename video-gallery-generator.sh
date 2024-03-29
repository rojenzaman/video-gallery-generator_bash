#!/bin/bash

# video-gallery-generator.sh
# Author: Rojen Zaman <rojen@riseup.net>
#        https://github.com/rojenzaman/video-gallery-generator_bash (video gallery generator)
# Inspired by: Nils Knieling
#    https://github.com/Cyclenerd/gallery_shell (image gallery generator)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

# RULES:
# - Videos must be MP4.
# - Subtitle files must be VTT.
# - Subtitle filenames must be the same as video files.
# - Videos must have a title and artist metadata to be displayed as a title in the html page if not called by their filename.


#########################################################################################
#### Function Section
#########################################################################################
generate_index_html() {
echo "<!DOCTYPE HTML>
<html lang='tr'>
<head>
	<meta charset='utf-8'>
	<title>$title</title>
	<meta name='viewport' content='width=device-width'>
	<meta name='robots' content='noindex, nofollow'>
	<meta name='generator' content='$0' />
	<link rel='stylesheet' href='$stylesheet'>
        <style>
            body {
            color: white;
            background-color: black;
            }
        </style>
</head>
<body>
<div class='container'>
	<div class='row'>
		<div class='col-xs-12'>
			<div class='page-header'><h1>$title</h1></div>
		</div>
	</div>
"
if [[ $(find . -maxdepth 1 -type f -iname \*.mp4 | wc -l) -gt 0 ]]; then
echo "<div class='row'>"
    if [[ $sflag == true ]]; then
echo "    <div class='col-xs-12'>"
fi
    numfiles=0
    for filename in *.[mM][pP][4]; do
        filelist[$numfiles]=$filename
        (( numfiles++ ))
        if [[ ! -s $thumbdir/$filename ]]; then
            debugOutput "$thumbdir/$filename"
            if [[ ! $sflag == true ]]; then
                duration=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$filename")
                ffmpeg -y -ss "$(echo $duration/2 | bc)" -i "$filename" -q:v 2 -vframes 1 "$thumbdir/$filename.jpg"
            fi
        fi
	get_title=""
	if [[ ! $qflag == true ]]; then
		get_title=$(exiftool -b -Title "$filename")
	fi
        if [[ -z "$get_title" ]]; then
            video_title="$filename"
        else
            video_title="$get_title"
        fi

        if [[ $sflag == true ]]; then
echo "            <a href='$thumbdir/$filename.html' class='btn btn-primary' role='button'><span class='glyphicon glyphicon-film' aria-hidden='true'></span> $video_title</a>"
        else
echo "            <div class='col-md-3 col-sm-12'>
            <p>
                $video_title
                <a href='$thumbdir/$filename.html'><img src='$thumbdir/$filename.jpg' alt='' class='img-responsive'></a>
                <div class='hidden-md hidden-lg'><hr></div>
            </p>
            </div>"
            if [[ $((numfiles % 4)) -eq 0 ]]; then
echo "                <div class='clearfix visible-md visible-lg'></div>"
            fi
        fi
    done
echo ""
    if [[ $sflag == true ]]; then
echo "    </div>"
    fi
echo "</div>"
fi


if [[ $(find . -maxdepth 1 -type f -iname \*.vtt | wc -l) -gt 0 ]]; then
echo "
    <div class='row'>
		<div class='col-xs-12'>
			<div class='page-header'><h3>VTT Files</h3></div>
		</div>
	</div>
	<div class='row'>
	<div class='col-xs-12'>"
	for filename in *.[vV][tT][tT]; do
echo "		<a href='$filename' class='btn btn-primary' role='button'>$downloadicon $filename</a>"
	done
echo "    </div>
</div>"
fi
echo "<hr>
<footer>
	<p>$footer</p>
	<p class='text-muted'>$datetime</p>
</footer>
</div> 
</body>
</html>"

}
generate_video_player() {
echo "<!DOCTYPE HTML>
<html lang='tr'>
<head>
<meta charset='utf-8'>
<title>$video_title $video_artist</title>
<meta name='viewport' content='width=device-width'>
<meta name='robots' content='noindex, nofollow'>
<meta name='generator' content='$0' />
<link rel='stylesheet' href='$stylesheet'>
<link rel='stylesheet' href='$plyr_css' />
	<style>
		body {
		color: white;
		background-color: black;
		}
		.pager li > a, .pager li > span {
		display: inline-block;
		padding: 5px 14px;
		background-color: #000;
		border: 2px solid #09ffff;
		border-radius: 15px;
		}
		a {
		color: #09ffff;
		text-decoration: none;
		}
		.btn-info {
		color: #000;
		background-color: #5bc0de;
		border-color: #46b8da;
		}
	</style>
</head>
<body>
<div class='container'>
<div class='row'>
	<div class='col-xs-12'>
		<div class='page-header'><h2><a href='../$_htmlfile'>$homeicon</a> <span class='text-muted'>/</span> $video_title $video_artist</h2></div>
	</div>
</div>

<div class='row'><div class='col-xs-12'><nav><ul class='pager'>
"
if [[ $prev ]]; then
echo "
    <li class='previous'><a href='$prev.html'><span aria-hidden='true'>&larr;</span></a></li>
"
fi
if [[ $next ]]; then
echo "
    <li class='next'><a href='$next.html'><span aria-hidden='true'>&rarr;</span></a></li>
"
fi
echo "
</ul></nav></div></div>


<div class='row'>
	<div class='col-md-7'>"
if [[ $sflag == true ]]; then
echo "	<video id='player' playsinline controls>"
else
echo "	<video poster='../$thumbdir/$filename.jpg' id='player' playsinline controls>"
fi
echo "    <source src='../$filename' type='video/mp4' />"
    base_filename=$(basename "$filename" .mp4)
    if [[ -f "$base_filename.vtt" ]]; then
        if [[ "$base_filename.vtt" == "$base_filename.vtt" ]]; then
echo "
    <track kind="captions" label="$subtitle_language" src="../$base_filename.vtt" srclang="$subtitle_code" default />
"
        fi
    fi
echo "</video>

<script src='$plyr_js'></script>
<script>
    const player = new Plyr('video', {captions: {active: true}});

// Expose player so it can be used from the console
window.player = player;
</script>

	</div>
</div>
<br>

<div class='row'>
	<div class='col-xs-12'>
		<p><a class='btn btn-info btn-lg' href='../$filename'>$downloadicon Download the video file ($filesize)</a></p>"
	if [[ "$base_filename.vtt" == "$base_filename.vtt" ]]; then
echo "		<p><a class='btn btn-info btn-lg' href='../$base_filename.vtt'>$vttdownloadicon Download the subtitle</a></p>"
	fi
echo "	</div>
</div>

"
	if [[ ! $eflag == true ]]; then
echo "
<br>
<div class='row'>
<div class='col-xs-12'>
<pre class='text-muted' style='background-color:black'>
$exifinfo
</pre>
</div>
</div>
"
	fi
echo "
</div>
</body>
</html>"

}
#########################################################################################
#### Configuration Section
#########################################################################################

thumbdir="video"
htmlfile="index.html"
tmpfs="/dev/shm"
title="Video Gallery"
footer='generated by <a href="./video-gallery-generator.sh">video-gallery-generator.sh</a>'
subtitle_language="English Subtitle"
subtitle_code="en"

# Use convert from ImageMagick
convert="convert"
# Use exiftool for EXIF Information
exif="exiftool"

stylesheet="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.4.1/css/bootstrap.min.css" #(currently v3.4.1)
plyr_css="https://cdnjs.cloudflare.com/ajax/libs/plyr/3.7.3/plyr.css"
plyr_js="https://cdnjs.cloudflare.com/ajax/libs/plyr/3.7.3/plyr.polyfilled.js"
downloadicon='<span class="glyphicon glyphicon-floppy-save" aria-hidden="true"></span>'
vttdownloadicon='<span class="glyphicon glyphicon-subtitles" aria-hidden="true"></span>'
movieicon='<span class="glyphicon glyphicon-film" aria-hidden="true"></span>'
homeicon='<span class="glyphicon glyphicon-home" aria-hidden="true"></span>'
#homeicon=".."

# Debugging output
# true=enable, false=disable
debug=false

#########################################################################################
#### End Configuration Section
#########################################################################################

script_name=$(basename "$0")
datetime=$(date -u "+%Y-%m-%d %H:%M:%S")
datetime+=" UTC"

function usage {
	returnCode="$1"
	echo -e "Usage: $script_name [-t <title>] [-d <thumbdir>] [-m] [-e] [-s] [-q] [-h]:
	[-t <title>]\\t sets the title (default: $title)
	[-d <thumbdir>]\\t sets the thumbdir (default: $thumbdir)
	[-m]\\t\\t use tmpfs for html generation (default: $tmpfs/vgg-$htmlfile)
	[-e]\\t\\t skip print exif data
	[-s]\\t\\t skip thumbnail generation
	[-q]\\t\\t skip author and title generation
	[-h]\\t\\t displays help (this message)"
	exit "$returnCode"
}

function debugOutput(){
	if [[ "$debug" == true ]]; then
		echo "$1" # if debug variable is true, echo whatever's passed to the function
	fi
}

function getFileSize(){
	# Be aware that BSD stat doesn't support --version and -c
	if stat --version &>/dev/null; then
		# GNU
		myfilesize=$(stat -c %s "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	else
		# BSD
		myfilesize=$(stat -f %z "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	fi
	echo "$myfilesize"
}

while getopts ":t:d:mesqh" opt; do
	case $opt in
	t)
		title="$OPTARG"
		;;
	d)
		thumbdir="$OPTARG"
		;;
	m)
		mflag="true"
		;;
	e)
		eflag="true"
		;;
	s)
		sflag="true"
		;;
	q)
		qflag="true"
		;;
	h)
		usage 0
		;;
	*)
		echo "Invalid option: -$OPTARG"
		usage 1
		;;
	esac
done

# Post configuration
debugOutput "- $script_name : $datetime"
if [[ $mflag == true ]]; then
	_htmlfile=$htmlfile
	htmlfile=$tmpfs/vgg-$htmlfile
fi

### Check Commands
command -v $convert >/dev/null 2>&1 || { echo >&2 "!!! $convert it's not installed.  Aborting."; exit 1; }
command -v $exif >/dev/null 2>&1 || { echo >&2 "!!! $exif it's not installed.  Aborting."; exit 1; }

### Create Folders
[[ -d "$thumbdir" ]] || mkdir "$thumbdir" || exit 2

#### Create Startpage
debugOutput "$htmlfile"


# generate index page
generate_index_html > $htmlfile

## Generate the HTML Files for videos in thumbdir
file=0
while [[ $file -lt $numfiles ]]; do
	filename=${filelist[$file]}
	prev=""
	next=""
	[[ $file -ne 0 ]] && prev=${filelist[$((file - 1))]}
	[[ $file -ne $((numfiles - 1)) ]] && next=${filelist[$((file + 1))]}
	imagehtmlfile="$thumbdir/$filename.html"
	if [[ ! $eflag == true ]]; then
		exifinfo=$($exif "$filename")
	fi
	filesize=$(getFileSize "$filename")
	debugOutput "$imagehtmlfile"
	get_title=""
	if [[ ! $qflag == true ]]; then
		get_title=$(exiftool -b -Title "$filename")
	fi
	if [[ -z "$get_title" ]]; then
		video_title="$filename"
	else
		video_title="$get_title"
	fi
	get_artist=""
	if [[ ! $qflag == true ]]; then
		get_artist=$(exiftool -b -Artist "$filename")
	fi
	if [[ -z "$get_artist" ]]; then
		video_artist=""
	else
		video_artist="- $get_artist"
	fi

	# generate video page
	generate_video_player > "$imagehtmlfile"

	(( file++ ))
done

if [[ $mflag = true ]]; then
	mv $htmlfile $_htmlfile
fi

debugOutput "= okay :)"
