{
  description = "Flake for multiple decompiled/reimplemented games.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    systems.flake = false;
    systems-linux.url = "github:nix-systems/default-linux";
    systems-linux.flake = false;
  };

  outputs = { self, systems, systems-linux, ... } @inputs: let
    helpers = import ./lib/helpers.nix { inherit inputs; };
    inherit (helpers) mkPackages mkApps;
  in {
    packages = mkPackages [
      {
        systems = import systems;
        packages = { pkgs, ... }: let inherit (pkgs) callPackage; in rec {
          # Xash3D FWGS Engine - Half-Life reimplementation
          hlsdk-portable = callPackage ./pkgs/hlsdk-portable {};
          xash3d-fwgs = callPackage ./pkgs/xash3d-fwgs {
            inherit hlsdk-portable;
          };

          # Zelda 64: Recompiled - Build tools
          z64decompress = callPackage ./pkgs/z64decompress {};
          n64recomp = callPackage ./pkgs/n64recomp {};

          # Super Mario 64 PC port
          sm64ex = sm64ex-us;
          sm64ex-us = callPackage ./pkgs/sm64ex { baseRom = "us"; };
          #sm64ex-eu = callPackage ./pkgs/sm64ex { baseRom = "eu"; };
          sm64ex-jp = callPackage ./pkgs/sm64ex { baseRom = "jp"; };

          # Zelda 3
          zelda3 = callPackage ./pkgs/snesrev/zelda3.nix {};
          smw = callPackage ./pkgs/snesrev/smw.nix {};
          sm = callPackage ./pkgs/snesrev/sm.nix {};
          smb1 = callPackage ./pkgs/snesrev/smb1.nix { inherit smw; };

          # Perfect Dark
          perfect-dark = pkgs.callPackage ./pkgs/perfect-dark {};
        };
      }
      {
        systems = import systems-linux;
        packages = { pkgs, system }: {
          # Zelda 64: Recompiled - Majora's Mask static recompilation
          zelda64recompiled = pkgs.callPackage ./pkgs/zelda64recompiled {
            inherit (self.packages."${system}") z64decompress n64recomp;
          };
          mariokart64recompiled = pkgs.callPackage ./pkgs/mariokart64recompiled {
            inherit (self.packages."${system}") n64recomp;
          };
        };
      }
    ];

    apps = mkApps self.packages;
  };
}
