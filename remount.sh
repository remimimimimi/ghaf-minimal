#!/usr/bin/env bash

set -e

nix build

OUT="./result"
MNT_DIR="./mnt"

START=$(fdisk -l $OUT/nixos.img | awk 'FNR == 10 {print $2}')
OFFSET=$(($START * 512))

sudo umount $MNT_DIR > /dev/null 2>&1 || true
sudo mount -o loop,offset=$OFFSET $OUT/nixos.img $MNT_DIR

# du -ahd 1 $MNT_DIR/nix/store | sort -rh | perl -e 'my@matches;push(@matches,$&)while(<>=~/^(.+)M/g);print$matches[0]-$matches[1],"M    Nix store size\n";'

du -ahd 1 $MNT_DIR/nix/store | sort -rh | head -n 21
