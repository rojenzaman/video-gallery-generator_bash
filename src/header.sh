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
