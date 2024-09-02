#/bin/bash

usage() {
        echo 'prep.sh <path to busybox binary location> <dir from where the symbolic links to be copied>'
}

if [ "$#" -ne 2 ]; then
    usage
    exit 2
fi

BUSYBOX_BIN_LOCATION=$1
SYMBOLIC_LINKS_PATH=$2

rm -rf initramfs_prep
mkdir -p ./initramfs_prep/bin

#copy busybox
cp $BUSYBOX_BIN_LOCATION ./initramfs_prep/bin
./copy_links.sh $SYMBOLIC_LINKS_PATH ./initramfs_prep/bin $BUSYBOX_BIN_LOCATION

#copy init script
cp init initramfs_prep/
chmod +x initramfs_prep/init

#build initrd file
cd initramfs_prep
find . | cpio -o -H newc | gzip --best > ../initramfs.cpio.gz
cd ..

rm -f ./boot

#create 20M boot image file
dd if=/dev/zero of=boot bs=1M count=20
#format the boot image file
mkfs -t fat boot

#install syslinux
syslinux boot

#mount the boot image file
tmp_folder=$(mktemp -d)
mount boot $tmp_folder

#copy all requred files
mkdir -p $tmp_folder/boot/syslinux
cp syslinux.cfg $tmp_folder/boot/syslinux
cp linux $tmp_folder/boot/linux
cp initramfs.cpio.gz $tmp_folder/boot/initramfs

#umount
umount $tmp_folder

#cleanup
rm -rf ./initramfs_prep
rm -rf ./initramfs.cpio.gz
