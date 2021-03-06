#!/bin/sh

echo "#############################################################"
echo "##                                                         ##"
echo "##        OpenWrt external root installation  script       ##"
echo "##                                                         ##"
echo "#############################################################"
#
printf "# select your filesystem, "ext4" or "f2fs:" "
read input_fs
if [[ $input_fs == "ext4" ]]; then
  export input_fs="ext4"
      echo
      echo "# you seleted $input_fs"
      echo "# installing, block-mount, kmod-fs-ext4, kmod-usb-storage, e2fsprogs, kmod-usb-ohci, kmod-usb-uhci..."
      echo
      sleep 2
      opkg install block-mount kmod-fs-ext4 kmod-usb-storage e2fsprogs kmod-usb-ohci kmod-usb-uhci;
fi

if [[ $input_fs == "f2fs" ]]; then
  export input_fs="f2fs"
      echo
      echo "# you seleted $input_fs"
      echo "# installing, block-mount, kmod-fs-f2fs, kmod-usb-storage, mkf2fs, f2fsck kmod-usb-ohci, kmod-usb-uhci..."
      echo
      sleep 2
      opkg install block-mount kmod-fs-f2fs kmod-usb-storage mkf2fs f2fsck kmod-usb-ohci kmod-usb-uhci;
fi

echo
echo "###############################"
echo "##      fstab & blkid?       ##"
echo "###############################"
echo
#
echo
echo "install fdisk & blkid? [Y,n]"
echo "/////////////////////////////"
echo
read input
if [[ $input == "Y" || $input == "y" ]]; then
  echo
        echo "# Installing fdisk & blkid..."
        sleep 2
        opkg install blkid fdisk
fi

echo
echo "###############################"
echo "##    Format filesystem      ##"
echo "###############################"
echo
echo "Format the filesystem on /dev/sda1 ? [Y,n] "
echo "////////////////////////////////////"
echo
read input
if [[ $input == "Y" || $input == "y" ]]; then
  echo
        echo "# formatting sda1..."
        if [[ $input_fs == "ext4" ]]; then
           mkfs.ext4 /dev/sda1
        fi
     
        if [[ $input_fs == "f2fs" ]]; then
           mkfs.f2fs /dev/sda1
  fi
fi

echo
echo "###############################"
echo "##     show block info       ##"
echo "###############################"
echo

block info

if [ -e "/dev/sda*" || -e "/dev/sdb*" ]; then
	echo "# USB/MMC found, transferring content to new /overlay"
	echo
        sleep 1
        mount /dev/sda1 /mnt ; tar -C /overlay -cvf - . | tar -C /mnt -xf - ; umount /mnt
        sleep2
 else
        echo
        echo "# Device not showed up, maybe forgot to plug in?"
        sleep 1
        echo
        echo "# Exiting now!"
        sleep 3
  exit

fi

# echo "# Did your device showed up? [Y,n]"
# echo "/////////////////////////////////"
# read input
# if [[ $input == "Y" || $input == "y" ]]; then
#        echo "# Transferring content to new /overlay"
#        echo
#        sleep 1
#        mount /dev/sda1 /mnt ; tar -C /overlay -cvf - . | tar -C /mnt -xf - ; umount /mnt
#        sleep2
# else
#        echo
#        echo "# Device not showed up, maybe forgot to plug in?"
#        sleep 1
#        echo
#        echo "# Exiting now!"
#        sleep 3
#  exit
#
# fi

echo
echo "# Generate fstab automatically "
echo "///////////////////////////////"
echo
block detect > /etc/config/fstab; \
   sed -i s/option$'\t'enabled$'\t'\'0\'/option$'\t'enabled$'\t'\'1\'/ /etc/config/fstab; \
   sed -i s#/mnt/sda1#/overlay# /etc/config/fstab; \
   cat /etc/config/fstab;
   mkdir /mnt/sda2
   sleep 2

   echo
   echo " ####################  Script finished, Fstab generated!  ####################### "
   echo " # If mounting fails after reboot, review the configuration in "/etc/config/fstab ""
   echo " //////////////////////////////////////////////////////////////////////////////// "
   echo
   sleep 4
   echo " exiting now... "
   sleep 2
   exit

