{ runCommand, stdenv, lib, writeText, linux_latest, linuxManualConfig, busybox, cpio, ... }:
let
  baseKernel = linux_latest;
  kernel = linuxManualConfig {
    inherit stdenv lib;
    inherit (baseKernel) src version modDirVersion;
    configfile = ./mini-linux.config;
    # we need this to true else the kernel can't parse the config and
    # detect if modules are in used
    allowImportFromDerivation = true;
  };
  busybox' = busybox.override { enableStatic = true; };
  init = writeText "init" ''
    #!/bin/sh

    mount -t proc none /proc
    mount -t sysfs none /sys

    cat <<!


    Boot took $(cut -d' ' -f1 /proc/uptime) seconds

            _       _     __ _
      /\/\ (_)_ __ (_)   / /(_)_ __  _   ___  __
     /    \| | '_ \| |  / / | | '_ \| | | \ \/ /
    / /\/\ \ | | | | | / /__| | | | | |_| |>  <
    \/    \/_|_| |_|_| \____/_|_| |_|\__,_/_/\_\


    Welcome to mini_linux


    !
    exec /bin/sh
  '';
in
runCommand "build-mini-linux" { } ''
  mkdir -p $out/initramfs
  cp ${kernel}/bzImage $out
  cp -r ${busybox'}/bin $out/initramfs/
  cp ${init} $out/initramfs/init
  chmod +x $out/initramfs/init
  cd $out/initramfs
  find . -print0 | ${cpio}/bin/cpio --null -ov --format=newc \
    | gzip -9 > ../initramfs.cpio.gz
''
