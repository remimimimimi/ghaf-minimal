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
      "/system/activation/activation-script.nix"
      "/misc/nixpkgs.nix"
      "/system/boot/kernel.nix"
      "/misc/assertions.nix"
      "/misc/lib.nix"
      "/config/sysctl.nix"

      # # TODO: Replace with less bloated modules
      # "/system/boot/systemd.nix"
    ]
    ++ builtins.map (p: modulesPath + p) [
      "/system/boot/init.nix"
      "/system/boot/systemd.nix"
      "/config/system-path.nix"
    ] ++ [
      ({ lib, config, pkgs, ... }: {
        _module.args = {
          utils = import (nixpkgs + "/nixos/lib/utils.nix") { inherit lib config pkgs; };
        };
      })
    ];

  evalConfig = modules:
    nixpkgs.lib.evalModules {
      modules = baseModules ++ modules;
    };
}
