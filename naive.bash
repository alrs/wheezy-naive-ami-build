#!/usr/bin/env bash

set -x 

RAW_IMAGE=/mnt/wheezy-instance-`date +%s`.raw
TARGET_DIR=/target
IMAGE_SIZE=9000

service dbus stop
service udev stop

dd if=/dev/zero of=$RAW_IMAGE bs=1M count=$IMAGE_SIZE

mkfs.xfs -L instanceroot $RAW_IMAGE

mount -o loop $RAW_IMAGE $TARGET_DIR

http_proxy=http://localhost:3142/ debootstrap wheezy $TARGET_DIR

cp -R assets/* $TARGET_DIR

chroot $TARGET_DIR apt-get update
chroot $TARGET_DIR mount -t proc none /proc
chroot $TARGET_DIR mount -t devpts none /dev/pts
chroot $TARGET_DIR apt-get -y install locales locales-all
chroot $TARGET_DIR apt-get -y install vim-nox ssh git-core sudo xfsprogs ntp
chroot $TARGET_DIR service ssh stop
chroot $TARGET_DIR service ntp stop
chroot $TARGET_DIR apt-get -y -t wheezy-backports install initramfs-tools
chroot $TARGET_DIR apt-get -y -t wheezy-backports install linux-image-3.12-0.bpo.1-amd64
chroot $TARGET_DIR insserv -r /etc/init.d/hwclock.sh
chroot $TARGET_DIR insserv -d /etc/init.d/ec2-get-credentials
chroot $TARGET_DIR insserv -d /etc/init.d/ec2-run-user-data
chroot $TARGET_DIR insserv -d /etc/init.d/generate-ssh-hostkeys

rm $TARGET_DIR/etc/ssh/ssh_host*

cp -R assets/* $TARGET_DIR

umount $TARGET_DIR/proc
umount $TARGET_DIR/dev/pts
umount $TARGET_DIR

echo $RAW_IMAGE
