#!/bin/bash

# configure SATIP server name/IP address, here
SERVER="192.168.1.114"
#SERVER="192.168.178.42"

# cleanup old files
rm *.php
rm *.xml
rm /tmp/pos*.xml
P1=19.2E
P2=28.2E
P3=23.5E
P4=13E

declare -a P
P=($P1 $P2 $P3 $P4 )

# download PHP files from kingofsat
wget https://de.kingofsat.net/pos-$P1.php
wget https://de.kingofsat.net/pos-$P2.php
wget https://de.kingofsat.net/pos-$P3.php
wget https://de.kingofsat.net/pos-$P4.php

# call python script to extract channel information from php files and generate m3u files
# the number at the end of the call is the satip src parameter (diseqc position)
python getchannels.py $SERVER pos-$P1.php 1
python getchannels.py $SERVER pos-$P2.php 2
python getchannels.py $SERVER pos-$P3.php 3
python getchannels.py $SERVER pos-$P4.php 4

# merge all xml files together
STR2='<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">'
STR3='</channelTable>'

echo $STR2 > allChannels.xml
cat pos-$P*.xml >> allChannels.xml
echo $STR3 >> allChannels.xml

for i in "${P[@]}";
do
(echo $STR2 && cat pos-$i.xml) > /tmp/pos-$i.xml && cat /tmp/pos-$i.xml > pos-$i.xml && (cat pos-$i.xml && echo $STR3) >> /tmp/posN-$i.xml && cat /tmp/posN-$i.xml > pos-$i.xml ;
done


