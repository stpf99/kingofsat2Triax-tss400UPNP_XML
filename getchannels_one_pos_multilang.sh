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
echo $STR2 > AllChannels.xml
for i in "${L[@]}";
do
wget "https://de.kingofsat.net/freqs.php?&pos=$P&standard=All&ordre=freq&filtre=Clear&cl=$i"
mv "freqs.php?&pos=$P&standard=All&ordre=freq&filtre=Clear&cl=$i" tv-$P-fta-$i.php
python getchannels.py $SERVER tv-$P-fta-$i.php 1
cat tv-$P-fta-$i.xml | awk '{ sub(/NR/, ++i) } 1' |  sed 's/&//g' | sed 's/>V</>v</g' | sed 's/>H</>h</g' >> TV-$P-FTA-$i.xml
done
cat TV-$P-FTA-*.xml >> AllChannels.xml
echo $STR3 >> AllChannels.xml

mkdir ONEPOSMULTILANG/
mv AllChannels.xml ONEPOSMULTILANG/
rm *.php *.xml freq*
