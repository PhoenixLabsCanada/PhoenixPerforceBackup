#!/usr/bin/env bash

cp ./config.sh /tmp/config.sh.phoenix
cp ./getNewVersion.sh /tmp/getNewVersion.sh
/usr/bin/git fetch
/usr/bin/git reset --hard origin/master
mv /tmp/getNewVersion.sh ./getNewVersion.sh
mv /tmp/config.sh.phoenix ./config.sh
