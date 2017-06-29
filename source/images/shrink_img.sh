#!/bin/bash


echo $0

#example:
# sh shrink_img.sh ~/Documents/nicole-blog/source/images/blog/5th-line-5k-race-report

find $1 -type f -name '*' -exec sh -c '
	filename=$(basename "$0")
	extension="${filename##*.}"
	filename="${filename%.*}"
	dir=$(dirname "$0")

	echo "Shrinking...$0 to $filename.jpg"

	convert "$0" -resize 1000x1000\> -quality  80% "$dir/$filename.jpg"
	
	if [ "$extension" != "jpg" ]
	then
		echo "DELETING...$0"
		rm "$0"
	fi
' {} ';'
