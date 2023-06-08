{ runCommand, stdenv, lib, writeText, closureInfo, callPackage, linux_latest, linuxManualConfig, systemd, systemdMinimal, busybox, cpio, shadow, ... }:
let
  baseKernel = linux_latest;
  kernel = baseKernel;
  busybox' = busybox;

  # systemd' = callPackage ./systemd { };
  # systemd' = systemd.override {
  #   withSelinux = false;
  #   withLibseccomp = false;
  #   withKexectools = false;
  #   # withAcl = false;
  #   withAnalyze = false;
  #   withApparmor = false;
  #   # withAudit = false;
  #   withCompression = false;
  #   withCoredump = false;
  #   withCryptsetup = false;
  #   withDocumentation = false;
  #   withEfi = stdenv.hostPlatform.isEfi;
  #   withFido2 = false;
  #   withHomed = false;
  #   withHostnamed = false;
  #   withHwdb = false;
  #   withImportd = false;
  #   # withKmod = false;
  #   withLibBPF = false;
  #   # withLibidn2 = false;
  #   withLocaled = false;
  #   withLogind = false;
  #   withMachined = false;
  #   withNetworkd = false;
  #   withNss = false;
  #   withOomd = false;
  #   # withPam = false;
  #   withPCRE2 = false;
  #   withPolkit = false;
  #   withPortabled = false;
  #   withRemote = false;
  #   withResolved = false;
  #   withShellCompletions = false;
  #   withTimedated = false;
  #   withTimesyncd = false;
  #   withTpm2Tss = false;
  #   # withUkify = false;
  #   withUserDb = false;
  #   withUtmp = false;
  #   withTests = false;
  # };
  systemd' = systemdMinimal;
  systemClosureInfo = closureInfo {
    rootPaths = [
      # busybox'
      systemd'
    ];
  };
  agettyStub = writeText "agetty" ''
    #!/bin/sh
    exec /bin/sh
  '';
  # FIXME
  rescueService = writeText "rescue.service" ''
    #  SPDX-License-Identifier: LGPL-2.1-or-later
    #
    #  This file is part of systemd.
    #
    #  systemd is free software; you can redistribute it and/or modify it
    #  under the terms of the GNU Lesser General Public License as published by
    #  the Free Software Foundation; either version 2.1 of the License, or
    #  (at your option) any later version.

    [Unit]
    Description=Rescue Shell
    Documentation=man:sulogin(8)
    DefaultDependencies=no
    Conflicts=shutdown.target
    After=sysinit.target plymouth-start.service
    Before=shutdown.target

    [Service]
    Environment=HOME=/root
    WorkingDirectory=-/root
    # ExecStartPre=-/nix/store/3zq94mlidvqr3fmkibw1migvp9k3lv7z-systemd-minimal-251.16/bin/plymouth --wait quit
    ExecStart=/bin/sh
    Type=idle
    StandardInput=tty-force
    StandardOutput=inherit
    StandardError=inherit
    KillMode=process
    IgnoreSIGPIPE=no
    SendSIGHUP=yes
  '';
in
runCommand "build-mini-linux" { } ''
  mkdir -p $out/initramfs
  cp ${kernel}/bzImage $out

  cd $out/initramfs

  mkdir -p ./nix/store
  for entry in  $(cat ${systemClosureInfo}/store-paths)
  do
    cp -r $entry ./nix/store
  done

  ln -s ./nix/store/$(${busybox}/bin/basename ${systemd'})/bin/init init
  ln -s ${busybox}/bin ./bin

  mkdir ./etc && cp -r ${systemd'}/example/* ./etc
  # chown -R $(whoami) ./etc

  chmod -R +w ./etc

  mkdir ./root
  rm ./etc/systemd/system/rescue.service
  cp ${rescueService} ./etc/systemd/system/rescue.service

  find . -print0 | ${cpio}/bin/cpio --null -ov --format=newc \
    | gzip -9 > ../initramfs.cpio.gz
''
