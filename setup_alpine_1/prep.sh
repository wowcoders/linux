#!/bin/sh

rm -f ./boot

#create 5120M boot image file
dd if=/dev/zero of=boot bs=1M count=5120
#format the boot image file
mkfs -t ext4 boot
losetup -P /dev/loop8 boot

#mount the boot image file
tmp_folder=$(mktemp -d)
mount /dev/loop8 $tmp_folder


#install alpine linux
./install_alpine.sh $tmp_folder


#install extlinux
mkdir -p $tmp_folder/boot/extlinux
extlinux -i $tmp_folder/boot/extlinux

#copy all requred files
cp extlinux.conf $tmp_folder/boot/extlinux

#umount
umount $tmp_folder
losetup -d /dev/loop8

#cleanup
rm minirootfs.tgz
