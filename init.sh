#!/bin/bash
# populates LOWER folder
set -xe

# Create required directories
mkdir -p ./LOWER/bin ./LOWER/sbin ./LOWER/lib ./LOWER/proc ./LOWER/sys ./LOWER/tmp ./LOWER/dev \
    ./LOWER/usr/bin ./LOWER/usr/lib ./LOWER/usr/include ./LOWER/usr/share ./LOWER/usr/src ./LOWER/usr/sbin \
    ./LOWER/usr/local/bin ./LOWER/usr/local/lib ./LOWER/usr/local/etc ./LOWER/usr/local/share ./LOWER/usr/local/include \
    ./LOWER/etc ./LOWER/run ./LOWER/var/log ./LOWER/var/cache ./LOWER/var/spool ./LOWER/opt ./LOWER/home ./LOWER/root 

# Copy setup script if it exists
if [ -f setup.sh ]; then
    cp setup.sh ./LOWER/home/
    chmod +x ./LOWER/home/setup.sh
fi

# Install busybox symlinks to bin directory
cp ./busybox ./LOWER/bin/
chmod +x ./LOWER/bin/busybox
./LOWER/bin/busybox --install -s ./LOWER/bin

# Create basic configuration files
echo "root:x:0:0:root:/root:/bin/bash" > ./LOWER/etc/passwd
echo "tester:x:1000:1000:tester:/home/tester:/bin/bash" >> ./LOWER/etc/passwd

echo "root:x:0:" > ./LOWER/etc/group
echo "tester:x:1000:" >> ./LOWER/etc/group

echo "127.0.0.1 localhost" > ./LOWER/etc/hosts
echo "sandbox" > ./LOWER/etc/hostname

# Create a minimal init script
cat > ./LOWER/etc/profile << 'EOF'
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PS1='\u@sandbox:\w\$ '
alias ls='ls --color=auto'
cd /home
EOF

# Create a minimal /etc/fstab
cat > ./LOWER/etc/fstab << 'EOF'
proc    /proc    proc    defaults    0    0
sysfs   /sys     sysfs   defaults    0    0
tmpfs   /tmp     tmpfs   defaults    0    0
EOF

# Make the home directory for tester
mkdir -p ./LOWER/home/tester
chown 1000:1000 ./LOWER/home/tester
