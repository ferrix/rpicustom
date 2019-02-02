#!/bin/bash -eu

pushd /root

if [ -z $(which zip) ] || [ -z $(which unzip) ] || [ -z $(which strings) ] || [ -z $(which mkpasswd) ]; then
    packages="zip unzip binutils whois"
    apt-get install -y $packages || apt-get update && apt-get install -y $packages
fi

image_zip=$(cat vendor/latest_image)
image_img=$(echo $image_zip | sed 's/\.zip/.img/')
target_zip=$(echo $image_zip | sed 's/-lite/-cluster/')

if [ ! -f dist/$image_img ]; then
    pushd dist
    unzip ../vendor/$image_zip
    popd
fi

pushd dist
mkdir -p boot root

sizes=($(fdisk -l $image_img | grep -e 'Sector size' -e img[0-9] | sed 's/Sector size //' | awk '{ print $2 }'))
bootoffset=$(perl -e "print ${sizes[0]}*${sizes[1]}")
rootoffset=$(perl -e "print ${sizes[0]}*${sizes[2]}")

bootloop=$(losetup -f)
losetup -o $bootoffset $bootloop $image_img
rootloop=$(losetup -f)
losetup -o $rootoffset $rootloop $image_img

mount -v -t vfat $bootloop boot
mount -v -t ext4 $rootloop root

echo "Enabling SSH"
touch boot/ssh

echo "Enabling BOOT_UART"
if [ ! -z $(strings boot/bootcode.bin | grep BOOT_UART=0) ]; then
    sed -i 's/BOOT_UART=0/BOOT_UART=1/' boot/bootcode.bin
fi

echo "Enabling cgroups"
if [ -z "$(grep cgroup_enable boot/cmdline.txt)" ]; then
    sed -i 's/^/cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory /' boot/cmdline.txt
fi

echo "Adding authorized keys"
piuid=$(chroot root id -u pi)
pigid=$(chroot root id -g pi)

mkdir -p root/home/pi/.ssh
cp ../config/authorized_keys root/home/pi/.ssh
chown -R $piuid:$pigid root/home/pi/.ssh
chmod 700 root/home/pi/.ssh
chmod 600 root/home/pi/.ssh/authorized_keys

# Set default password
hash=$(mkpasswd -m sha-512 $(cat ../config/defaultpass))
sed -i "/^pi:/ s#:[^:]*#:$hash#" root/etc/shadow

function cleanup() {
    for loop in $(mount | grep loop | awk '{ print $1 }'); do
        umount $loop
        losetup -d $loop
    done
}

cleanup
zip $target_zip $image_img
popd
popd
