{
  description = "Flake for multiple decompiled/reimplemented games.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    systems.flake = false;
    systems-linux.url = "github:nix-systems/default-linux";
    systems-linux.flake = false;
  };

  outputs = { self, nixpkgs, systems, systems-linux } @inputs: let
    helpers = import ./helpers.nix { inherit inputs; };
    inherit (helpers) mkPackages mkApps;
  in {
    packages = mkPackages [
      {
        systems = import systems;
        packages = { pkgs, ... }:let inherit (pkgs) callPackage; in rec {
          # Xash3D FWGS Engine - Half-Life reimplementation
          waf-setup-hook = callPackage ./pkgs/waf-setup-hook {};
          hlsdk-portable = callPackage ./pkgs/hlsdk-portable {
            inherit waf-setup-hook;
          };
          xash3d-fwgs = callPackage ./pkgs/xash3d-fwgs {
            inherit waf-setup-hook hlsdk-portable;
          };

          # Zelda 64: Recompiled - Majora's Mask static recompilation
          z64decompress = callPackage ./pkgs/z64decompress {};
          n64recomp = callPackage ./pkgs/n64recomp {};
        };
      }
      {
        systems = import systems-linux;
        packages = { pkgs, system }: {
          zelda64recompiled = pkgs.callPackage ./pkgs/zelda64recompiled {
            inherit (self.packages."${system}") z64decompress n64recomp;
          };
        };
      }
    ];

    apps = mkApps self.packages;
  };
}
