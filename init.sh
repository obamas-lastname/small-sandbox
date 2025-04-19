#!/bin/bash

# populates LOWER folder
set -xe
mkdir -p ./LOWER/sbin ./LOWER/lib ./LOWER/usr/bin ./LOWER/usr/lib ./LOWER/usr/include ./LOWER/usr/share ./LOWER/usr/src ./LOWER/usr/sbin \
    ./LOWER/usr/local/bin ./LOWER/usr/local/lib ./LOWER/usr/local/etc ./LOWER/usr/local/share ./LOWER/usr/local/include \
    ./LOWER/etc ./LOWER/tmp ./LOWER/run ./LOWER/var/log ./LOWER/var/cache ./LOWER/var/spool ./LOWER/opt ./LOWER/home ./LOWER/root ./LOWER/bin

cp ./busybox ./LOWER/bin/

busybox --install -s
echo "tester:x:0:0::/tester:/bin/bash" > ./LOWER/etc/passwd
echo "tester:x:0:tester" > ./LOWER/etc/group
echo "127.0.0.1 localhost localhost.localdomain" > ./LOWER/etc/hosts

# ip link set dev lo up
# hostname minibox

# cd $HOME
# exec sh --login