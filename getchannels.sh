#!/bin/bash

# configure SATIP server name/IP address, here
SERVER="192.168.1.114"
#SERVER="192.168.178.42"

# cleanup old files
rm *.php
rm *.xml
$1=19.2E
$2=28.2E
$3=23.5E
$4=13E

$ALL=$(1,2,3,4, 'allChannels')
# download PHP files from kingofsat
wget https://de.kingofsat.net/pos-$1.php
wget https://de.kingofsat.net/pos-$2.php
wget https://de.kingofsat.net/pos-$3.php
wget https://de.kingofsat.net/pos-$4.php

# call python script to extract channel information from php files and generate m3u files
# the number at the end of the call is the satip src parameter (diseqc position)
python getchannels.py $SERVER pos-$1.php 1
python getchannels.py $SERVER pos-$2.php 2
python getchannels.py $SERVER pos-$3.php 3
python getchannels.py $SERVER pos-$4.php 4

# merge all xml files together
cat *.xml >> allChannels.xml


$2="<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">"
$3="</channelTable>"


(echo $2 && cat pos-$ALL.xml) > /tmp/pos-$ALL.xml
cat /tmp/pos-$ALL.xml > pos-$ALL.xml

echo $3 >> $ALL.xml
