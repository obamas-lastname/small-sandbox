#!/bin/bash
set -e
pwd=$(pwd)
dothings(){
    # Prepare the directories
    mkdir -p LOWER UPPER WORK
    mkdir -p ROOTFS
    chmod 755 ROOTFS

    # Add busybox to ROOTFS so it can be seen before overlay
    mkdir -p ROOTFS/bin
    cp ./busybox ROOTFS/bin/
    chmod +x ./ROOTFS/bin/busybox

    cp /bin/bash ./ROOTFS/bin/
    # Call init.sh to prepare LOWER
    ./init.sh

    # Fix ownership (VERY IMPORTANT for user namespace + FUSE)
    chown -R $(id -u):$(id -g) LOWER UPPER WORK ROOTFS

    # Mount overlay as unprivileged user
    fuse-overlayfs -o lowerdir="$pwd"/LOWER,upperdir="$pwd"/UPPER,workdir="$pwd"/WORK "$pwd"/ROOTFS

    # Run sandbox
    unshare -mipunUr chroot ROOTFS /bin/bash
        # chroot ROOTFS /bin/busybox sh -c '
        #     mount -t proc proc /proc
        #     mount -t sysfs sys /sys
        #     mount -t tmpfs tmpfs /tmp
        #     echo "✅ Welcome to your unprivileged sandbox!"
        #     /bin/busybox sh
        # ' 
}


cleanup() {
    sudo fusermount3 -u ROOTFS
    sudo rm -rf ROOTFS
}

cleanup
dothings