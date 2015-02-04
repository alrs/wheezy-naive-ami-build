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

debootstrap wheezy $TARGET_DIR

cp -R assets/* $TARGET_DIR

chroot $TARGET_DIR apt-get update
chroot $TARGET_DIR mount -t proc none /proc
chroot $TARGET_DIR mount -t devpts none /dev/pts
chroot $TARGET_DIR apt-get -y install locales locales-all
chroot $TARGET_DIR apt-get -y install vim-nox ssh git-core sudo xfsprogs ntp ruby ruby1.9.1 curl lsb-release python2.7-dev python-pip python-virtualenv pciutils resolvconf haveged htop
chroot $TARGET_DIR service ssh stop
chroot $TARGET_DIR service ntp stop
chroot $TARGET_DIR service haveged stop
chroot $TARGET_DIR apt-get -y -t wheezy-backports install initramfs-tools
chroot $TARGET_DIR apt-get -y -t wheezy-backports install linux-image-3.16.0-0.bpo.4-amd64
chroot $TARGET_DIR pip install awscli
chroot $TARGET_DIR insserv -r /etc/init.d/hwclock.sh
chroot $TARGET_DIR insserv -d /etc/init.d/ec2-get-credentials
chroot $TARGET_DIR insserv -d /etc/init.d/ec2-run-user-data
chroot $TARGET_DIR insserv -d /etc/init.d/generate-ssh-hostkeys

rm $TARGET_DIR/etc/ssh/ssh_host*
rm $TARGET_DIR/var/cache/apt/archives/*.deb

cp -R assets/* $TARGET_DIR

umount $TARGET_DIR/proc
umount $TARGET_DIR/dev/pts
umount -l $TARGET_DIR

echo $RAW_IMAGE
