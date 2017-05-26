#!/bin/bash

njobs=$1
graphdir="exp/tdnn_7b_chain_online/graph_pp"
decodedir="exp/tdnn_7b_chain_online/decode_dev"
output=$2
append8="data/wav/8k"
curdir=$(pwd)
online_config="exp/tdnn_7b_chain_online/conf/online.conf"

# Checking arguments
if [ $# -lt 2 ]; then
        echo "Use $0 <njobs> <datadir>"
        exit 1;
fi
CORPUS=$2 #DATA_DIR

echo "Initializing $CORPUS"
if [ ! -d "$curdir/$append8/$CORPUS" ]; then
        echo "Creating $CORPUS directory"
        mkdir -p "$curdir/$append8/$CORPUS" || ( echo "Unable to create data dir" && exit 1 )
fi;
wav_scp=$curdir/$append8/$CORPUS/"wav.scp"
spk2utt=$curdir/$append8/$CORPUS/"spk2utt"
utt2spk=$curdir/$append8/$CORPUS/"utt2spk"
text=$curdir/$append8/$CORPUS/"text"

#nulling files
cat </dev/null >$wav_scp
cat </dev/null >$spk2utt
cat </dev/null >$utt2spk
cat </dev/null >$text
rm $CORPUS/feats.scp 2>/dev/null;
rm $CORPUS/cmvn.scp  2>/dev/null;
for file in $curdir/$append8/$CORPUS/*.wav; do
        id=$(echo $file | awk -F'/' '{print $NF}' |  sed -e 's/ /_/g')
        echo "$id $file" >>$wav_scp
        echo "$id $id" >>$spk2utt
        echo "$id $id" >>$utt2spk
        echo "$id NO_TRANSCRIPTION" >>$text
done;
sleep 1
sort -k1 $wav_scp -o $wav_scp
sleep 1
sort -k1 $spk2utt -o $spk2utt
sleep 1
sort -k1 $utt2spk -o $utt2spk
sleep 1
sort -k1 $text -o $text

echo "Done creating corpus"

echo "Run Decoding"

steps/online/nnet3/decode.sh \
--online false \
--nj $njobs \
--post_decode_acwt 10 \
--online-config $online_config \
--per-utt true \
--output-name $output \
$graphdir \
$append/$CORPUS \
$decodedir
