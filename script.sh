#!/bin/bash

startup() {
	sudo useradd -N -m tester &> /dev/null || true
	sudo passwd -d tester &> /dev/null

	sudo -u tester dd if=/dev/zero of=/home/tester/img bs=1M count=100
	sudo -u tester mkfs.ext4 /home/tester/img

	LOOPDEV=$(sudo losetup --find --show /home/tester/img)

	sudo mkdir -p /mnt/sandbox
	sudo mount "$LOOPDEV" /mnt/sandbox
}

cleanup() {
	sudo umount /mnt/sandbox
	sudo losetup -D
	sudo rm -rf /home/tester/img
	sudo rmdir /mnt/sandbox
	sudo userdel -r tester
}

startup