#!/bin/bash

cat src/header.sh > ${1}

echo "generate_index_html() {" >> ${1}
opt/pp/pp -d index.pp.html >> ${1}
echo "}" >> ${1}

echo "generate_video_player() {" >> ${1}
opt/pp/pp -d player.pp.html >> ${1}
echo "}" >> ${1}

cat src/main.sh >> ${1}

chmod +x ${1}
