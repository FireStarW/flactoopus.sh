#!/bin/bash

if [ "$1" == "" ];then
#no argument
var="cover.jpg"
	elif [ "$1" != "" ];then
		var=$1
fi

echo "================"
echo "Using $var"
echo "================"

dir=$(pwd)
parentname="$(dirname "$dir")"
artistname=$(basename "$parentname")
albumname=$(basename "$PWD")
convert $var  -resize 800x800  resize_cover.jpg
echo "Test output:"
echo "$artistname - $albumname"
mkdir "$artistname - $albumname"


for a in ./*.flac; do
  ffmpeg -i "$a" -b:a 192000 "${a[@]/%flac/opus}" &
done

wait
mv *.opus "$artistname - $albumname"
mv resize_cover.jpg "$artistname - $albumname"
cd "$artistname - $albumname"
kid3-cli -c "select all" -c 'set picture:"resize_cover.jpg" "resize_cover.jpg"' "*.opus"
rm resize_cover.jpg

for a in ./*.opus; do
file_size=$(stat --printf="%s" "$a")
if (( file_size < 500000 )); then
	echo "------------------------------------------------------------------"
	echo "!! WARNING: File size of $a is $file_size bytes !!"
fi
done

echo "Done"
