#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage $0 <trader-name> <njobs>"
	exit 1
fi

CORPUS=$1
nj=$2
curdir=$(pwd)
append16="data/wav/16k"
append8="data/wav/8k"
metadata="/usr/METADATA_AUDIO"
mp4="data/wav/mp4"

echo "Njobs are $nj"
echo "Trader name is $CORPUS"

if [ ! -d $mp4/$CORPUS ]
then
	echo "Nothing to transcode" || exit 1
else
	if [ ! "$(ls -A $curdir/$append8/$CORPUS/*.wav)" ]
	then
		cd $curdir/$mp4/$CORPUS
		sleep 1
		if [ -f $metadata/metadata_before_$CORPUS.txt ]
		then
			rm $metadata/metadata_before_$CORPUS.txt
		fi
		for file in * # Collects metadata of the extracted files
		do
			a=$(ffprobe -i $file -show_entries format=duration -v quiet -of csv="p=0" | awk -F'.' '{print $(1)}') # Duration of audio
			aa=$(ffprobe -i $file -show_entries format=duration -v quiet -of csv="p=0")
			b=$(ffprobe -v error -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 $file) # Sample rate of audio
			c=$(ffprobe -v error -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 $file) # Number of channels
			d=$(ffprobe -v error -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 $file) # Bit rate
			echo $file, $aa, $b, $c, $d >> $metadata/metadata_before_$CORPUS.txt # Saves in this file
			if [[ $a -le 20 ]]
			then
				if [[ $b -ge 16000 ]] # Duration filter
				then
					ffmpeg -y -i $file -acodec pcm_s16le -ar 16000 -ac 1 $curdir/$append16/$CORPUS/${file%.*}.wav -v quiet # Converts to .wav
					ffmpeg -y -i $file -acodec pcm_s16le -ar 8000 -ac 1 $curdir/$append8/$CORPUS/${file%.*}.wav -v quiet # Converts to .wav
				fi
			fi
		done
		echo "Create Corpus"
		cd $curdir
		./create-corpus.sh $nj $CORPUS || exit 1
	else
		echo "Crate Corpus"
		./create-corpus.sh $nj $CORPUS || exit 1
	fi
fi

sleep 1

echo "COPYING 16KHZ TRANSCODING FILES TO GOOGLE STORAGE"
gsutil -m cp -r $curdir/$append16/$CORPUS gs://model-development/HMM/Wav/

sleep 1

echo "Done Transcoding"
