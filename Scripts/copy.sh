#!/bin/bash

echo "$0 $@"  # Print the command line for logging
[ -f ./path.sh ] && . ./path.sh; # source the path.

if [ $# -ne 3 ]
then
	echo "Usage copy.sh <njobs> <trader-name> <google-storage-path>"
	echo "e.g. $0 16 matt 355/1142"
	exit 1
fi

curdir=$(pwd)
srcdir="/home/kaldi/egs/aspire/s5"
append16="data/wav/16k"
append8="data/wav/8k"
mp4="data/wav/mp4"

if [ $curdir != $srcdir ]
then
	echo "-------- Run this script from '/home/kaldi/egs/aspire/s5' ---------" || exit 1
fi

nj=$1
echo "Nj is $nj"

filename=$2
echo "Trader is $filename"

gspath=$3
echo "Google storage path is $gspath"

echo " Creating $filename folders in data/wav/16k and data/wav/8k"
if [ ! -d $append16/$filename ]
then
	mkdir -p $curdir/$append16/$filename
fi
if [ ! -d $append8/$filename ]
then
	mkdir -p $curdir/$append8/$filename
fi
if [ ! -d $mp4/$filename ]
then
	mkdir -p $curdir/$mp4/$filename
fi

echo "Copying $gspath from Google storage"

sleep 1
if [ ! "$(ls -A  $curdir/$mp4/$filename)" ]
then
	gsutil -m cp gs://production-c9tec/$gspath/*.mp4 $curdir/$mp4/$filename/
fi

echo "Transcoding..."
./transcoding.sh $filename $nj || exit 1

echo
echo "----------- Finished ------------"
