#!/usr/bin/env bash

set -e

nix build

OUT="./result"
MNT_DIR="./mnt"

START=$(fdisk -l $OUT/nixos.img | awk 'FNR == 10 {print $2}')
OFFSET=$(($START * 512))

sudo umount $MNT_DIR > /dev/null 2>&1 || true
sudo mount -o loop,offset=$OFFSET $OUT/nixos.img $MNT_DIR
