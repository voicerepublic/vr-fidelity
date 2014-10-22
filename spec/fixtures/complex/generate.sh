#!/bin/sh

# cleanup
rm *.flv *.wav

# generate timestamps
TS0=`date +%s`
TS1=$(( $TS0 + 1 ))
TS2=$(( $TS1 + 1 ))
TS3=$(( $TS2 + 2 ))

# generate fragments
sox -n t1-u1-$TS0.wav synth 1 sine 100-200
sox -n t1-u2-$TS1.wav synth 1 sine 200-100
sox -n t1-u1-$TS2.wav synth 2 sine 100-400
sox -n t1-u2-$TS3.wav synth 2 sine 400-100

# merge fragments to result
sox -m t1-u1-$TS0.wav "|sox t1-u2-$TS1.wav -p pad 1" "|sox t1-u1-$TS2.wav -p pad 2" "|sox t1-u2-$TS3.wav -p pad 4" 1.wav

# convert fragments to flv
avconv -y -i t1-u1-$TS0.wav -acodec libspeex -ar 16k -ac 1 t1-u1-$TS0.flv
avconv -y -i t1-u2-$TS1.wav -acodec libspeex -ar 16k -ac 1 t1-u2-$TS1.flv
avconv -y -i t1-u1-$TS2.wav -acodec libspeex -ar 16k -ac 1 t1-u1-$TS2.flv
avconv -y -i t1-u2-$TS3.wav -acodec libspeex -ar 16k -ac 1 t1-u2-$TS3.flv


