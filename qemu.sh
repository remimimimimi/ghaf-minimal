#!/usr/bin/env sh

qemu-system-x86_64 \
    -kernel ./result/bzImage \
    -initrd ./result/initramfs.cpio.gz \
    -append "console=ttyS0 systemd.unit=rescue.target" -enable-kvm -nographic \
    -m 512M
