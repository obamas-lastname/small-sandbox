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

for CMD in sh ls cat mkdir mount umount echo ps ls chmod; do
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

