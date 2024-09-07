{
  pkgs,
  lib,
  baseRom ? "us",
  enable60fps ? true,
  ...
}:

let
  inherit (lib) optional optionalString;
  inherit (pkgs.gccStdenv) isDarwin;

  romFile = {
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

  rom = pkgs.requireFile rec {
    name = "sm64.${baseRom}.z64";
    message = ''
      A Super Mario 64 ${romFile.name} ROM is required to build this package."
      You can add it to the Nix store with:
       $ nix-store --add-fixed sha256 ${name}
    '';
    hash = romFile.hash;
  };
in pkgs.gccStdenv.mkDerivation {
  pname = "sm64ex-${baseRom}";
  version = "nightly-2024-07-03";

  src = pkgs.fetchFromGitHub {
    owner = "sm64pc";
    repo = "sm64ex";
    rev = "20bb444562aa1dba79cf6adcb5da632ba580eec3";
    hash = "sha256-nw+F0upTetLqib5r5QxmcOauSJccpTydV3soXz9CHLQ";
  };

  nativeBuildInputs = with pkgs; [
    gnumake
    python3
    hexdump
  ] ++ optional isDarwin (with pkgs; [
    pkg-config
    djgpp
  ]);

  buildInputs = (with pkgs; [
    libGL
    SDL2
  ]) ++ optional isDarwin (with pkgs; [
    darwin.apple_sdk.frameworks.OpenGL
    glew.dev
  ]);

  patches = optional enable60fps [
    "enhancements/60fps_ex.patch"
  ] ++ optional isDarwin [
    ./patches/macos-hacks.patch
  ];

  enableParallelBuilding = true;
  makeFlags = [ "VERSION=${baseRom}" ];

  prePatch = ''
    patchShebangs --build .
    ln -s ${rom} baserom.${baseRom}.z64
  '';

  preBuild = optionalString pkgs.stdenv.isDarwin ''
    NIX_LDFLAGS="$NIX_LDFLAGS -F${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks"
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/${baseRom}_pc/sm64.${baseRom}.f3dex2e "$out/bin/sm64ex"
    runHook postInstall
  '';

  meta = {
    description = "Super Mario 64 PC port.";
    mainProgram = "sm64ex";
  };
}
