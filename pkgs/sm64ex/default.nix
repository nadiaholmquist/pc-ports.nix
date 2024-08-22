{ pkgs, lib, baseRom, ... }:

# TODO: Support other versions than US
# Maybe also toggling the 60FPS patch?

let
  inherit (lib) optional;
  inherit (pkgs.stdenv) isDarwin;

  rom = {
    us = {
      name = "USA";
      hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
    };
    eu = {
      name = "Europe";
      hash = "sha256-x5Ll68ujTI2YwMRM8pdHyO5n57kH/Md4h/n/JSP4BXI=";
    };
    jp = {
      name = "Japan";
      hash = "sha256-nPeoDbMhsHqNRh/lNsAsh7dBJDOVOJHN7JGRv60tsxc=";
    };
    # Does not compile - probably upstream issue.
    #sh = {
    #  name = "Japan (Shindou Edition)";
    #  hash = "sha256-+IB7XijxsaMcXTZ10j7Oc/lJzLVT3LsHlyZmoedq36I=";
    #};
  }."${baseRom}";
in pkgs.stdenv.mkDerivation {
  pname = "sm64ex-${baseRom}";
  version = "nightly-2024-07-03";

  srcs = [
    (pkgs.fetchFromGitHub {
      owner = "sm64pc";
      repo = "sm64ex";
      rev = "20bb444562aa1dba79cf6adcb5da632ba580eec3";
      hash = "sha256-nw+F0upTetLqib5r5QxmcOauSJccpTydV3soXz9CHLQ";
    })
    (pkgs.requireFile {
      name = "sm64.${baseRom}.z64";
      message = ''
        A Super Mario 64 ${rom.name} ROM is required to build this package."
      '';
      hash = rom.hash;
    })
  ];

  patches = [
    ./patches/detect-nix.patch
    "enhancements/60fps_ex.patch"
  ];

  nativeBuildInputs = (with pkgs; [
    gnumake
    python3
    hexdump
  ])
  ++ optional isDarwin (with pkgs; [
    gcc
    pkg-config
    # For `as`
    # Target architecture doesn't matter.
    gcc-arm-embedded
  ]) ++ [
    (pkgs.callPackage ../copy-rom-hook {})
  ];

  buildInputs = (with pkgs; [
    libGL
    SDL2
  ]) ++ optional isDarwin [
    pkgs.darwin.apple_sdk.frameworks.OpenGL
    pkgs.glew.dev
  ];

  enableParallelBuilding = true;
  makeFlags = [ "VERSION=${baseRom}" ];

  postUnpack = ''
    mv rom.z64 source/baserom.${baseRom}.z64
  '';

  postPatch = ''
    patchShebangs --build .
  '';

  preConfigure = lib.optionalString pkgs.stdenv.isDarwin ''
    NIX_LDFLAGS="$NIX_LDFLAGS -F${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks"
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/${baseRom}_pc/sm64.${baseRom}.f3dex2e "$out/bin/sm64ex"
    runHook postInstall
  '';

  meta.description = "Super Mario 64 PC port.";
  passthru.exeName = "sm64ex";
}
