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

#only downscale if res bigger than 800
convert $var  -resize 800x800\>  resize_cover.jpg

echo "artistname - albumname:"
echo "$artistname - $albumname"

flacprefix='[FLAC]'
#remove [FLAC]
if [[ "$albumname" == *"$flacprefix"* ]];then
  echo "Flac Suffix is there."
  albumname=${albumname/FLAC*/}
  albumname=${albumname%??}
  echo "$albumname"
fi
sixteenprefix='[16B'
#remove [16B-
if [[ "$albumname" == *"$sixteenprefix"* ]];then
  echo "16B Suffix is there."
  albumname=${albumname/16B*/}
  albumname=${albumname%??}
  echo "$albumname"
fi
#remove later
if [[ "$artistname" == ".lAteR" ]]; then
foldername=$albumname
  echo "later prefix is there."
else
foldername="$artistname - $albumname"
fi 

echo "foldername:"
echo "$foldername"

mkdir "$foldername"

for a in ./*.flac; do
  ffmpeg -i "$a" -b:a 192000 "${a[@]/%flac/opus}" &
done

wait
mv *.opus "$foldername"
mv resize_cover.jpg "$foldername"
cd "$foldername"
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
