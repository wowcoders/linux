#!/bin/sh

ROOT_FS_DIR=$1

wget -O minirootfs.tgz https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.2-x86_64.tar.gz

rm -rf $ROOT_FS_DIR
mkdir -p $ROOT_FS_DIR
tar -zxvf minirootfs.tgz -C $ROOT_FS_DIR

cd $ROOT_FS_DIR

cat > ./etc/resolv.conf <<-EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 2620:0:ccc::2
nameserver 2001:470:20::2
EOF

cat > ./etc/network/interfaces <<-EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p ./etc/apk

cat > ./etc/apk/repositories <<-EOF
http://dl-cdn.alpinelinux.org/alpine/v3.20/main
http://dl-cdn.alpinelinux.org/alpine/v3.20/community
EOF

cat > ./root/.profile <<-EOF
if [ -z "\$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"

	mkdir -pm 0700 "\$XDG_RUNTIME_DIR"
	export XDG_RUNTIME_DIR
fi
EOF

cd ..

chroot $ROOT_FS_DIR /bin/ash <<"EOT"
apk add tzdata
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

apk add openssh openrc lsblk weston weston-backend-drm seatd weston-backend-wayland weston-shell-desktop weston-terminal font-dejavu
apk add eudev udev-init-scripts
apk add chromium

echo "root:" | chpasswd -e

rc-update add seatd

rc-update add udev sysinit
rc-update add udev-trigger sysinit
rc-update add udev-settle sysinit
rc-update add udev-postmount default

rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add cgroups sysinit

rc-update add hwclock boot
rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc boot
rc-update add swap boot
rc-update add networking boot

rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

apk add linux-lts linux-firmware-none acpi mkinitfs
EOT
