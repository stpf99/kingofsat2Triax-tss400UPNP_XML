#!/bin/bash

# configure SATIP server name/IP address, here
SERVER="192.168.1.114"
#SERVER="192.168.178.42"

# cleanup old files
rm *.php
rm *.xml
P1=19.2E
P2=28.2E
P3=23.5E
P4=13E

ALL=(1,2,3,4, 'allChannels')
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
cat *.xml >> allChannels.xml


STR2="<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">"
STR3="</channelTable>"


(echo $STR2 && cat pos-$ALL.xml) > /tmp/pos-$ALL.xml
cat /tmp/pos-$ALL.xml > pos-$ALL.xml

echo $3 >> $ALL.xml
