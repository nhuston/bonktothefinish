#!/bin/bash


echo $0

#example:
# sh source/images/shrink_img.sh ~/Documents/nicole-blog/source/images/blog/cat-names

# To convert a single image - example:
# convert site-header-img.jpg -resize 1000x1000\> -quality  80% site-header-img.jpg

find $1 -type f -name '*' -exec sh -c '
	filename=$(basename "$0")
	extension="${filename##*.}"
	filename="${filename%.*}"
	dir=$(dirname "$0")

	echo "Shrinking...$0 to $filename.jpg"

	convert "$0" -resize 1700x1700\> -quality  70% "$dir/$filename.jpg"

	if [ "$extension" != "jpg" ]
	then
		echo "DELETING...$0"
		rm "$0"
	fi
' {} ';'
