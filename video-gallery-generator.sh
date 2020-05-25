#!/bin/bash

# gallery.sh
# Author: Rojen Zaman - https://github.com/rojenzaman/video-gallery-generator_bash (video gallery generator)
# Inspired by: Nils Knieling - https://github.com/Cyclenerd/gallery_shell (image gallery generator)
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


#########################################################################################
#### Configuration Section / Konfigürasyon Bölümü
#########################################################################################

quality="320x240"
thumbdir="__thumbs"
htmlfile="index.html"
title="Gallery"
footer='<a href="./video-gallery-generator.sh">video-gallery-generator.sh</a> ile yaratıldı'

# Use convert from ImageMagick / ImageMagick'ten dönüştürmeyi kullanma
convert="convert" 
# Use exiftool for EXIF Information / Exif bilgisi için exiftool programını kullanma
exif="exiftool"

# Bootstrap (currently v3.4.1)
stylesheet="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.4.1/css/bootstrap.min.css"

downloadicon='<span class="glyphicon glyphicon-floppy-save" aria-hidden="true"></span>'
movieicon='<span class="glyphicon glyphicon-film" aria-hidden="true"></span>'
#homeicon='<span class="glyphicon glyphicon-home" aria-hidden="true"></span>'
homeicon=".."

# Debugging output / Debug çıktısı
# true=enable, false=disable
debug=true

# VTT exist

altyazi=`ls | grep "vtt"`

if [ -z "$altyazi" ]
then
echo "altyazı yok"
else
echo "alt yazı var"
vtt="<track kind=\"captions\" label=\"Türkçe Altyazı\" src=\"../$altyazi\" srclang=\"tr\" default />"
fi

#########################################################################################
#### End Configuration Section / Konfigürasyon bölümünün sonu
#########################################################################################




me=$(basename "$0")
datetime=$(date -u "+%Y-%m-%d %H:%M:%S")
datetime+=" UTC"

function usage {
	returnCode="$1"
	echo -e "Usage: $me [-t <title>] [-d <thumbdir>] [-h]:
	[-t <title>]\\t sets the title (default: $title)
	[-d <thumbdir>]\\t sets the thumbdir (default: $thumbdir)
	[-h]\\t\\t displays help (this message)"
	exit "$returnCode"
}

function debugOutput(){
	if [[ "$debug" == true ]]; then
		echo "$1" # if debug variable is true, echo whatever's passed to the function  / hata ayıklama değişkeni true değerini döndürüse, fonksiyona ne geçerse yazılır
	fi
}

function getFileSize(){
	# Be aware that BSD stat doesn't support --version and -c / BSD de dosya bilgisinin --version ve -c yi desteklemediğini unutmayın
	if stat --version &>/dev/null; then
		# GNU
		myfilesize=$(stat -c %s "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	else
		# BSD
		myfilesize=$(stat -f %z "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	fi
	echo "$myfilesize"
}

while getopts ":t:d:h" opt; do
	case $opt in
	t)
		title="$OPTARG"
		;;
	d)
		thumbdir="$OPTARG"
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

debugOutput "- $me : $datetime"

### Check Commands / gerekli programın  varlığını kontrol et
command -v $convert >/dev/null 2>&1 || { echo >&2 "!!! $convert it's not installed.  Aborting."; exit 1; }
command -v $exif >/dev/null 2>&1 || { echo >&2 "!!! $exif it's not installed.  Aborting."; exit 1; }

### Create Folders / dizin yarat
[[ -d "$thumbdir" ]] || mkdir "$thumbdir" || exit 2







#### Create Startpage / Başlangıç sayfası oluştur
debugOutput "$htmlfile"
cat > "$htmlfile" << EOF
<!DOCTYPE HTML>
<html lang="tr">
<head>
	<meta charset="utf-8">
	<title>$title</title>
	<meta name="viewport" content="width=device-width">
	<meta name="robots" content="noindex, nofollow">
	<link rel="stylesheet" href="$stylesheet">
        <style>
            body {
            color: white;
            background-color: black;
            }
        </style>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-xs-12">
			<div class="page-header"><h1>$title</h1></div>
		</div>
	</div>
EOF

### Videos (MP4) / Videolar
if [[ $(find . -maxdepth 1 -type f -iname \*.mp4 | wc -l) -gt 0 ]]; then

echo '<div class="row">' >> "$htmlfile"
## Generate Images / Thumb dosyası oluştur
numfiles=0
for filename in *.[mM][pP][4]; do
	filelist[$numfiles]=$filename
	(( numfiles++ ))
		if [[ ! -s $thumbdir/$filename ]]; then
			debugOutput "$thumbdir/$filename"
			duration=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$filename")
			ffmpeg -ss "$(echo $duration/2 | bc)" -i "$filename" -q:v 2 -vframes 1 "$thumbdir/$filename.jpg"
		fi
	cat >> "$htmlfile" << EOF
<div class="col-md-3 col-sm-12">
	<p>
		$filename
		<a href="$thumbdir/$filename.html"><img src="$thumbdir/$filename.jpg" alt="" class="img-responsive"></a>
		<div class="hidden-md hidden-lg"><hr></div>
	</p>
</div>
EOF
[[ $((numfiles % 4)) -eq 0 ]] && echo '<div class="clearfix visible-md visible-lg"></div>' >> "$htmlfile"
done
echo '</div>' >> "$htmlfile"

## Generate the HTML Files for videos in thumbdir / 
file=0
while [[ $file -lt $numfiles ]]; do
	filename=${filelist[$file]}
	prev=""
	next=""
	[[ $file -ne 0 ]] && prev=${filelist[$((file - 1))]}
	[[ $file -ne $((numfiles - 1)) ]] && next=${filelist[$((file + 1))]}
	imagehtmlfile="$thumbdir/$filename.html"
	exifinfo=$($exif "$filename")
	filesize=$(getFileSize "$filename")
	debugOutput "$imagehtmlfile"
	cat > "$imagehtmlfile" << EOF
<!DOCTYPE HTML>
<html lang="tr">
<head>
<meta charset="utf-8">
<title>$filename</title>
<meta name="viewport" content="width=device-width">
<meta name="robots" content="noindex, nofollow">
<link rel="stylesheet" href="$stylesheet">
<link rel="stylesheet" href="https://cdn.plyr.io/3.5.6/plyr.css" />
        <style>
            body {
            color: white;
            background-color: black;
            }
        </style>
</head>
<body>
<div class="container">
<div class="row">
	<div class="col-xs-12">
		<div class="page-header"><h2><a href="../$htmlfile">$homeicon</a> <span class="text-muted">/</span> $filename</h2></div>
	</div>
</div>
EOF

	# Pager
	echo '<div class="row"><div class="col-xs-12"><nav><ul class="pager">' >> "$imagehtmlfile"
	[[ $prev ]] && echo '<li class="previous"><a href="'"$prev"'.html"><span aria-hidden="true">&larr;</span></a></li>' >> "$imagehtmlfile"
	[[ $next ]] && echo '<li class="next"><a href="'"$next"'.html"><span aria-hidden="true">&rarr;</span></a></li>' >> "$imagehtmlfile"
	echo '</ul></nav></div></div>' >> "$imagehtmlfile"

	cat >> "$imagehtmlfile" << EOF
<div class="row">
	<div class="col-md-7">
<video poster="../$thumbdir/$filename.jpg" id="player" playsinline controls>
    <source src="../$filename" type="video/mp4" />
    $vtt
</video>


<script src="https://cdn.plyr.io/3.5.6/plyr.polyfilled.js"></script>
<script>
    const player = new Plyr('video', {captions: {active: true}});

// Expose player so it can be used from the console
window.player = player;
</script>


	</div>
</div>
<br>

<div class="row">
	<div class="col-xs-12">
		<p><a class="btn btn-info btn-lg" href="../$filename">$downloadicon Dosyayı İndir ($filesize)</a></p>
	</div>
</div>
EOF

	# EXIF
#Exif information can be displayed after clicking the button.

	if [[ $exifinfo ]]; then
		cat >> "$imagehtmlfile" << EOF


<div id="exif-show" class="thumbs" onclick="tikla('exif')">
<button type="button" class="btn btn-primary">dosya bilgisi</button>
</div>
<div id="exif" style="visibility: hidden">
<br>
<div class="row"><div class="col-xs-12">
<pre>
$exifinfo
</pre>
</div></div>
</div>
<script>
function tikla(i) {
    document.getElementById(i).style.visibility='visible';
}
</script>






EOF
	fi

	# Footer / alt bölüm
	cat >> "$imagehtmlfile" << EOF
</div>
</body>
</html>
EOF
	(( file++ ))
done

fi





### Downloads (ZIP) / İndirmeler
if [[ $(find . -maxdepth 1 -type f -iname \*.vtt | wc -l) -gt 0 ]]; then
	cat >> "$htmlfile" << EOF
	<div class="row">
		<div class="col-xs-12">
			<div class="page-header"><h2>vtt dosyaları</h2></div>
		</div>
	</div>
	<div class="row">
	<div class="col-xs-12">
EOF
	for filename in *.[vV][tT][tT]; do
		filesize=$(getFileSize "$filename")
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$downloadicon $filename ($filesize)</a>
EOF
	done
	echo '</div></div>' >> "$htmlfile"
fi

### Footer / alt bölüm
cat >> "$htmlfile" << EOF
<hr>
<footer>
	<p>$footer</p>
	<p class="text-muted">$datetime</p>
</footer>
</div> <!-- // container -->
</body>
</html>
EOF

debugOutput "= tamamdır :)"


