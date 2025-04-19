#!/bin/busybox 
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp
echo "✅ Welcome to your unprivileged sandbox!"
#exec sh --login