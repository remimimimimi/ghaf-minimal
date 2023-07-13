{
  description = "Ghaf - Documentation and implementation for TII SSRC Secure Technologies Ghaf Framework";

  inputs = {
    nixpkgs.url = "github:remimimimimi/nixpkgs-ghaf/ghaf-minimal-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixos-generators,
  }: let
    systems = with flake-utils.lib.system; [
      x86_64-linux
      aarch64-linux
      aarch64-darwin
    ];
  in
    # Combine list of attribute sets together
    nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate {} [
      (flake-utils.lib.eachSystem systems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        nixosConfigurations = rec {
          raw = nixpkgs.lib.nixosSystem {
            modules = [
              {
                system.stateVersion = "23.05";
              }
              ({
                pkgs,
                lib,
                modulesPath,
                ...
              }: {
                imports = [
                  (modulesPath + "/profiles/minimal.nix")
                ];

                environment.defaultPackages = lib.mkForce [];
                environment.systemPackages = lib.mkForce [];

                # Keep the only required file in etc to see big dependencies clearly
                environment.etc = lib.mkForce {
                  "modprobe.d/nixos.conf".source = ./empty.txt;
                };

                # nix.enable = false;
                boot.enableContainers = false;
                # # FIXME: Save for the bright future
                boot.initrd.systemd.enable = true;
                boot.growPartition = lib.mkForce false;

                nixpkgs.overlays = [
                  # (import ./overlays/busybox.nix)

                  (self: super: let
                    systemd = super.systemd.override {
                      pname = "systemd-ghaf";
                      withAcl = false;
                      withAnalyze = false;
                      withApparmor = false;
                      withAudit = false;
                      withCompression = false;
                      withCoredump = false;
                      withCryptsetup = false;
                      withDocumentation = false;
                      withEfi = false;
                      withFido2 = false;
                      withHostnamed = false;
                      withHomed = false;
                      withHwdb = false;
                      withImportd = false;
                      withLibBPF = false;
                      withLibidn2 = false;
                      withLocaled = false;
                      withLogind = false;
                      withMachined = false;
                      withNetworkd = false;
                      withNss = false;
                      withOomd = false;
                      withPCRE2 = false;
                      withPam = false;
                      withPolkit = false;
                      withPortabled = false;
                      withRemote = false;
                      withResolved = false;
                      withShellCompletions = false;
                      withTimedated = false;
                      withTimesyncd = false;
                      withTpm2Tss = false;
                      withUserDb = false;
                    };
                  in {
                    # Deduplicate systemd
                    inherit systemd;
                    systemdMinimal = systemd;
                  })
                ];
              })

              nixos-generators.nixosModules.raw-efi
              ({
                pkgs,
                lib,
                config,
                modulesPath,
                ...
              }: {
                system.build.raw = lib.mkForce (import "${toString modulesPath}/../lib/make-disk-image.nix" {
                  inherit lib config pkgs;
                  partitionTableType = "efi";
                  diskSize = "auto";
                  format = "raw";
                  installBootLoader = false; # TEMPORARY
                  copyChannel = false;
                });

                boot.initrd.enable = false;

                # TEMPORARY
                boot.kernel.enable = false;
              })

              # nixos-generators.nixosModules.iso
            ];
            inherit system;
          };
        };
        formatter = pkgs.alejandra;
        packages.default = let cfg = self.nixosConfigurations.${system}.raw.config; in cfg.system.build.${cfg.formatAttr};
      }))
    ];
}
