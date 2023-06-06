{ self
, nixpkgs ? self.inputs.nixpkgs
,
}:
rec {
  baseModules =
    let
      nixosModulesPath = nixpkgs + "/nixos/modules";
      modulesPath = ../modules;
    in
    builtins.map (p: nixosModulesPath + p) [
      "/system/etc/etc.nix"
      # "/system/activation/activation-script.nix"
      "/misc/nixpkgs.nix"
      "/system/boot/kernel.nix"
      "/misc/assertions.nix"
      "/misc/lib.nix"
      "/config/sysctl.nix"
      "/tasks/filesystems.nix"
      # # TODO: Replace with less bloated modules
      # "/system/boot/systemd.nix"
    ]
    ++ builtins.map (p: modulesPath + p) [
      # "/system/boot/init.nix"
      # "/system/boot/stage-1.nix"
      # "/system/boot/stage-2.nix"
      "/system/boot/systemd.nix"
      "/system/activation/activation-script.nix"
      "/config/system-path.nix"
      "/stub.nix"
    ] ++ [
      ({ lib, config, pkgs, ... }: {
        _module.args = {
          utils = import (nixpkgs + "/nixos/lib/utils.nix") { inherit lib config pkgs; };
        };
      })
      ({...}: {
        # boot.isContainer = true;
        boot.initrd.enable = false;
        imports = [
          "${toString nixosModulesPath}/virtualisation/qemu-vm.nix"
        ];


        formatAttr = "vm";
      })
    ];

  evalConfig = modules:
    nixpkgs.lib.evalModules {
      modules = baseModules ++ modules;
    };
}
