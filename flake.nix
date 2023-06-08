{
  description = "Ghaf - Documentation and implementation for TII SSRC Secure Technologies Ghaf Framework";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    let
      systems = with flake-utils.lib.system; [
        x86_64-linux
        aarch64-linux
      ];
    in
    # Combine list of attribute sets together
    nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate { } [
      (flake-utils.lib.eachSystem systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.alejandra;
        # NOTE: Run with `./qemu.sh`
        packages.default = pkgs.callPackage ./mini-linux.nix { };
      }))
    ];
}
