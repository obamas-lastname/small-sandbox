#!/bin/bash
set -e
pwd=$(pwd)

cleanup() {
    # Only attempt to unmount if the directory exists and is mounted
    if [ -d ROOTFS ] && mountpoint -q ROOTFS 2>/dev/null; then
        fusermount3 -u ROOTFS
    fi
    # Clean up directories but don't fail if they don't exist
    rm -rf ROOTFS UPPER WORK LOWER 2>/dev/null || true
}

# Clean up from previous runs
cleanup

addfiles() {
    mkdir LOWER
    mkdir LOWER/home
    for file in "$@"; do
        echo "Copying $file to ./LOWER/home..."
        cp -r "$file" ./LOWER/home/tester
    done
}

dothings(){
    # Prepare the directories
    mkdir -p LOWER UPPER WORK
    mkdir -p ROOTFS
    chmod 755 ROOTFS
    
    # Add busybox to ROOTFS so it can be seen before overlay
    mkdir -p ROOTFS/bin
    cp ./busybox ROOTFS/bin/
    chmod +x ./ROOTFS/bin/busybox
    
    # Call init.sh to prepare LOWER
    chmod +x ./init.sh
    ./init.sh


    # Mount overlay as unprivileged user
    fuse-overlayfs -o lowerdir="$pwd"/LOWER,upperdir="$pwd"/UPPER,workdir="$pwd"/WORK "$pwd"/ROOTFS
    
    # Fix ownership (VERY IMPORTANT for user namespace + FUSE)
    chown -R $(id -u):$(id -g) LOWER UPPER WORK ROOTFS

    cat > ROOTFS/init << 'EOF'
#!/bin/busybox sh
export PATH=/bin:/sbin
/bin/busybox mount -t proc proc /proc
/bin/busybox mount -t sysfs sys /sys
/bin/busybox mount -t tmpfs tmpfs /tmp
echo "✅ Welcome to your unprivileged sandbox!"

exec /bin/busybox sh
EOF
    chmod +x ROOTFS/init

    ls -la ROOTFS/init
    
    
    # Run sandbox with properly mounted filesystems
    echo "Starting sandbox..."
    unshare -mipunUrf chroot ROOTFS /init
}



while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--files)
            shift
            files_to_copy=()
            while [[ $# -gt 0 && "$1" != -* ]]; do
                files_to_copy+=("$1")
                shift
            done
            addfiles "${files_to_copy[@]}"
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run the sandbox
dothings

# Clean up after exit
cleanup
