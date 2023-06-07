{ runCommand, stdenv, lib, writeText, closureInfo, linux_latest, linuxManualConfig, busybox, cpio, ... }:
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
  # busybox' = busybox.override { enableStatic = true; };
  busybox' = busybox;
  init = writeText "init" ''
    #! ${busybox'}/bin/sh

    ${busybox}/bin/ln -s ${busybox}/bin /bin

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

    exec ${busybox'}/bin/sh
  '';

  busyboxClosureInfo = closureInfo {
    rootPaths = [ busybox' ];
  };
in
runCommand "build-mini-linux" { } ''
  mkdir -p $out/initramfs
  cp ${kernel}/bzImage $out

  cd $out/initramfs

  mkdir -p .//nix/store
  for entry in  $(cat ${busyboxClosureInfo}/store-paths)
  do
    cp -r $entry ./nix/store
  done

  cp ${init} ./init
  chmod +x ./init

  find . -print0 | ${cpio}/bin/cpio --null -ov --format=newc \
    | gzip -9 > ../initramfs.cpio.gz
''
