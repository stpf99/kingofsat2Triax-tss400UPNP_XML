#!/bin/bash

# configure SATIP server name/IP address, here
SERVER="192.168.1.114"
#SERVER="192.168.178.42"

# cleanup old files
rm *.php
rm *.xml
rm -r pos/
# download PHP files from kingofsat
wget https://de.kingofsat.net/pos-19.2E.php
wget https://de.kingofsat.net/pos-28.2E.php
wget https://de.kingofsat.net/pos-23.5E.php
wget https://de.kingofsat.net/pos-13E.php

# call python script to extract channel information from php files and generate m3u files
# the number at the end of the call is the satip src parameter (diseqc position)
python getchannels.py $SERVER pos-19.2E.php 1
python getchannels.py $SERVER pos-28.2E.php 2
python getchannels.py $SERVER pos-23.5E.php 3
python getchannels.py $SERVER pos-13E.php 4

# merge all xml files together
cat *.xml >> allChannels.xml
(echo "<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">" && cat *.xml) > X*.xml && echo  "</channelTable>" >> X*.xml


