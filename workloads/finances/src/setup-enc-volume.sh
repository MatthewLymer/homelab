#!/bin/bash

sudo su

apt-get update && apt-get install -y cryptsetup

fallocate -l 1G /tmp/myvol.luks.dat

losetup -f --show /tmp/myvol.luks.dat # returns /dev/loop0 typically

cryptsetup luksFormat /dev/loop0

cryptsetup luksOpen /dev/loop0 c1

mkfs.ext4 /dev/mapper/c1

mount /dev/mapper/c1 /mnt/c1
