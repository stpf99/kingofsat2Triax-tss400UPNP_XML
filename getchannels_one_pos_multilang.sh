#!/bin/bash
# configure SATIP server name/IP address, here
SERVER="192.168.178.42"
# cleanup old files
rm *.php *.xml freq*
P=13E
L1=pol
L2=ger
L3=ita
L4=eng
declare -a L
L=($L1 $L2 $L3 $L4 )
STR2='<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">'
STR3='</channelTable>'
echo $STR2 > TV-$P-FTA-langs.xml
for i in "${L[@]}";
do
wget "https://de.kingofsat.net/freqs.php?&pos=$P&standard=All&ordre=freq&filtre=Clear&cl=$i"
done
cat freqs*  >> tv-$P-fta-langs.php
python getchannels.py $SERVER tv-$P-fta-langs.php 1
cat tv-$P-fta-langs.xml | awk '{ sub(/NR/, ++i) } 1' |  sed 's/&//g' | sed 's/>V</>v</g' | sed 's/>H</>h</g' >> TV-$P-FTA-langs.xml
echo $STR3 >> TV-$P-FTA-langs.xml

mkdir ONEPOSMULTILANG/
mv TV-$P-FTA-langs.xml ONEPOSMULTILANG/
rm *.php *.xml freq*
