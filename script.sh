#!/bin/bash
set -e
homedir=$(pwd)

unshare --mount --uts --pid --user --map-root-user --fork -- bash

startup() {
    # useradd -N -m tester &> /dev/null || true
    # passwd -d tester &> /dev/null

    dd if=/dev/zero of=/home/tester/img bs=1M count=100
   	mkfs.ext4 /home/tester/img

    LOOPDEV=$(sudo losetup --find --show /home/tester/img)

    mkdir -p /mnt/sandbox
    mount "$LOOPDEV" /mnt/sandbox

    # Setup basic dirs
    mkdir -p /mnt/sandbox/{bin,proc,sys,dev,home,tester}

    # Install busybox
    cp busybox /mnt/sandbox/bin/
    chmod +x /mnt/sandbox/bin/busybox
}

fsinit() {
    # Build basic rootfs
    cat <<EOF | sudo tee /mnt/sandbox/init.sh > /dev/null
#!/bin/busybox sh
set -xe

# Create dirs
mkdir -p /proc /sys /dev /etc /home/tester

# Install busybox
/bin/busybox --install -s

# Create passwd/group entries with tester as root
echo "tester:x:0:0::/home/tester:/bin/sh" > /etc/passwd
echo "root:x:0:" > /etc/group
echo "127.0.0.1 localhost" > /etc/hosts

cd /home/tester
exec /bin/sh
EOF

    chmod +x /mnt/sandbox/init.sh
}

enter_chroot() {
    chroot --userspec=0:0 /mnt/sandbox /init.sh
}

cleanup() {
    echo "[*] Cleaning up..."

    # Kill anything still using sandbox
    fuser -k /mnt/sandbox || true

    # Lazy unmount everything inside
    umount -l /mnt/sandbox/* 2>/dev/null || true
    umount -l /mnt/sandbox || true

    # Detach loop devices
    losetup -D

    # Clean image and dirs
    rm -rf /home/tester/img
    rmdir -rf /mnt/sandbox 2>/dev/null || true

    # Remove user
    #userdel -r tester 2>/dev/null || true
}


# Run in order
cleanup
