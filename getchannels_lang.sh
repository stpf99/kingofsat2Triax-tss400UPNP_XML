#!/bin/bash

# configure SATIP server name/IP address, here
SERVER="192.168.178.42"
#SERVER="192.168.178.42"
rm -r 1 2 3 4
mkdir 1 2 3 4
# cleanup old files
rm *.php
rm *.xml
rm /tmp/*.xml
P1=13.0E
P2=19.2E
P3=23.5E
P4=28.2E
#tv-13.0E-fta.php
declare -a P
P=($P1 $P2 $P3 $P4 )

# download PHP files from kingofsat
cd 1
#wget https://de.kingofsat.net/tv-$P1-fta.php
wget "https://de.kingofsat.net/freqs.php?&pos=13E&standard=All&ordre=freq&filtre=Clear&cl=pol"
mv 'freqs.php?&pos=13E&standard=All&ordre=freq&filtre=Clear&cl=pol' tv-$P1-fta.php
python ../getchannels.py $SERVER tv-$P1-fta.php 1
cd ..
cd 2
wget https://de.kingofsat.net/tv-$P2-fta.php
python ../getchannels.py $SERVER tv-$P2-fta.php 2
cd ..
cd 3
wget https://de.kingofsat.net/tv-$P3-fta.php
python ../getchannels.py $SERVER tv-$P3-fta.php 3
cd ..
cd 4
wget https://de.kingofsat.net/tv-$P4-fta.php
python ../getchannels.py $SERVER tv-$P4-fta.php 4
cd ..

cp */*.xml .
# call python script to extract channel information from php files and generate m3u files
# the number at the end of the call is the satip src parameter (diseqc position)
# add header and merge all xml files together
STR2='<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">'
STR3='</channelTable>'

echo $STR2 > AllChannels.xml
cat tv-*-fta.xml >> AllChannels.xml
echo $STR3 >> AllChannels.xml

for i in "${P[@]}";
do
awk '{ sub(/NR/, ++i) } 1' tv-$i-fta.xml >> /tmp/tv-$i-fta.xml && (echo $STR2 && cat /tmp/tv-$i-fta.xml && echo $STR3) > /tmp/tv-$i-fta-b.xml && sed 's/&//g' /tmp/tv-$i-fta-b.xml > /tmp/tv-$i-fta-clean.xml && cat /tmp/tv-$i-fta-clean.xml > /tmp/tv-$i-fta.xml && sed 's/>V</>v</g' /tmp/tv-$i-fta.xml >> /tmp/TV-$i-FTA.xml && sed 's/>H</>h</g' /tmp/TV-$i-FTA.xml >> Tv-$i-fta.xml  && awk '{ sub(/NR/, ++i) } 1' AllChannels.xml >> allChannels.xml && sed 's/&//g' allChannels.xml > SATIP_Channels.xml && sed 's/>V</>v</g' SATIP_Channels.xml > Channels.xml && sed 's/>H</>h</g'  Channels.xml > SATIP_Channels.xml ;
done
rm allChannels.xml AllChannels.xml tv*fta.xml
