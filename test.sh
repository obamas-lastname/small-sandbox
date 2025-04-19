#!/bin/bash
set -e
pwd=$(pwd)

cleanup() {
    # Only attempt to unmount if the directory exists and is mounted
    if [ -d ROOTFS ] && mountpoint -q ROOTFS 2>/dev/null; then
        fusermount3 -u ROOTFS
    fi
    # Clean up directories but don't fail if they don't exist
    rm -rf ROOTFS UPPER WORK 2>/dev/null || true
}

# Clean up from previous runs
cleanup

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
    chmod +x ./init.sh
    ./init.sh
    
    # Fix ownership (VERY IMPORTANT for user namespace + FUSE)
    chown -R $(id -u):$(id -g) LOWER UPPER WORK ROOTFS
    
    # Mount overlay as unprivileged user
    fuse-overlayfs -o lowerdir="$pwd"/LOWER,upperdir="$pwd"/UPPER,workdir="$pwd"/WORK "$pwd"/ROOTFS
    
    # Run sandbox with properly mounted filesystems
    unshare -mipunUr chroot ROOTFS /bin/bash -c '
        mount -t proc proc /proc
        mount -t sysfs sys /sys
        mount -t tmpfs tmpfs /tmp
        echo "✅ Welcome to your unprivileged sandbox!"
        /bin/bash
    '
}

# Run the sandbox
dothings

# Clean up after exit
cleanup
