#!/bin/bash
# populates LOWER folder
set -xe

# Create required directories
mkdir -p ./LOWER/bin ./LOWER/sbin ./LOWER/lib ./LOWER/proc ./LOWER/sys ./LOWER/tmp ./LOWER/dev \
    ./LOWER/usr/bin ./LOWER/usr/lib ./LOWER/usr/include ./LOWER/usr/share ./LOWER/usr/src ./LOWER/usr/sbin \
    ./LOWER/usr/local/bin ./LOWER/usr/local/lib ./LOWER/usr/local/etc ./LOWER/usr/local/share ./LOWER/usr/local/include \
    ./LOWER/etc ./LOWER/run ./LOWER/var/log ./LOWER/var/cache ./LOWER/var/spool ./LOWER/opt ./LOWER/home ./LOWER/root 


# Install busybox symlinks to bin directory
cp ./busybox ./LOWER/bin/
chmod +x ./LOWER/bin/busybox

COMMANDS="acpid adjtimex ar arch arp arping ascii ash awk base64 \
basename bc blkdiscard blkid blockdev brctl bunzip2 bzcat \
bzip2 cal cat chgrp chmod chown chroot chvt clear cmp cp \
cpio crc32 crond crontab cttyhack cut date dc dd deallocvt \
depmod devmem df diff dirname dmesg dnsdomainname dos2unix \
dpkg dpkg-deb du dumpkmap dumpleases echo ed egrep env expand \
expr factor fallocate false fatattr fdisk fgrep find findfs \
fold free freeramdisk fsfreeze fstrim ftpget ftpput getopt \
getty grep groups gunzip gzip halt head hexdump hostid \
hostname httpd hwclock i2cdetect i2cdump i2cget i2cset \
i2ctransfer id ifconfig ifdown ifup init insmod ionice ip \
ipcalc kill killall klogd last less link linux32 linux64 \
linuxrc ln loadfont loadkmap logger login logname logread \
losetup ls lsmod lsscsi lzcat lzma lzop md5sum mdev microcom \
mim mkdir mkdosfs mke2fs mkfifo mknod mkpasswd mkswap mktemp \
modinfo modprobe more mount mt mv nameif nbd-client nc \
netstat nl nologin nproc nsenter nslookup nuke od openvt \
partprobe passwd paste patch pidof ping ping6 pivot_root \
poweroff printf ps pwd rdate readlink realpath reboot renice \
reset resume rev rm rmdir rmmod route rpm rpm2cpio run-init \
run-parts sed seq setkeycodes setpriv setsid sh sha1sum \
sha256sum sha3sum sha512sum shred shuf sleep sort ssl_client \
start-stop-daemon stat strings stty su sulogin svc svok \
swapoff swapon switch_root sync sysctl syslogd tac tail tar \
taskset tc tee telnet test tftp time timeout top touch tr \
traceroute traceroute6 true truncate ts tty tunctl ubirename \
udhcpc udhcpc6 udhcpd uevent umount uname uncompress unexpand \
uniq unix2dos unlink unlzma unshare unxz unzip uptime usleep \
uudecode uuencode vconfig vi w watch watchdog wc wget which \
who whoami xargs xxd xz xzcat yes zcat"

for CMD in $COMMANDS; do
    ln -sf busybox ./LOWER/bin/$CMD
done

# Create basic configuration files
echo "root:x:0:0:root:/root:/bin/bash" > ./LOWER/etc/passwd
echo "tester:x:1000:1000:tester:/home/tester:/bin/bash" >> ./LOWER/etc/passwd

echo "root:x:0:" > ./LOWER/etc/group
echo "tester:x:1000:" >> ./LOWER/etc/group

echo "127.0.0.1 localhost" > ./LOWER/etc/hosts
echo "sandbox" > ./LOWER/etc/hostname

echo 'export PATH=/bin:/sbin' > ./LOWER/etc/profile

# recreate init script in LOWER for redundancy
cat > ./LOWER/init << 'EOF'
#!/bin/busybox sh
/bin/busybox mount -t proc proc /proc
/bin/busybox mount -t sysfs sys /sys
/bin/busybox mount -t tmpfs tmpfs /tmp

export PATH=/bin:/sbin
exec /bin/busybox sh
EOF
chmod +x ./LOWER/init

