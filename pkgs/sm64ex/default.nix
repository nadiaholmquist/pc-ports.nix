{ pkgs, lib, copy-rom-hook, ... }:

# TODO: Support other versions than US
# Maybe also toggling the 60FPS patch?

let
  inherit (lib) optional;
  inherit (pkgs.stdenv) isDarwin;
in pkgs.stdenv.mkDerivation {
  pname = "sm64ex";
  version = "nightly-2024-07-03";

  srcs = [
    (pkgs.fetchFromGitHub {
      owner = "sm64pc";
      repo = "sm64ex";
      rev = "20bb444562aa1dba79cf6adcb5da632ba580eec3";
      hash = "sha256-nw+F0upTetLqib5r5QxmcOauSJccpTydV3soXz9CHLQ";
    })
    (pkgs.requireFile {
      name = "sm64.us.z64";
      message = ''
        A Super Mario 64 ROM is required to build this package."
      '';
      sha256 = "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91";
    })
  ];

  patches = [
    ./patches/detect-nix.patch
    "enhancements/60fps_ex.patch"
  ];

  nativeBuildInputs = (with pkgs; [
    gnumake42
    python3
    hexdump
  ])
  ++ optional isDarwin (with pkgs; [
    gcc
    pkg-config
    # For `as`
    # Target architecture doesn't matter.
    gcc-arm-embedded
  ]) ++ [copy-rom-hook];

  buildInputs = (with pkgs; [
    libGL
    SDL2
  ]) ++ optional isDarwin [
    pkgs.darwin.apple_sdk.frameworks.OpenGL
    pkgs.glew.dev
  ];

  preConfigure = if isDarwin then ''
    NIX_LDFLAGS="$NIX_LDFLAGS -F${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks"
  '' else "";

  configurePhase = ''
    runHook preConfigure
    mv ../rom.z64 baserom.us.z64
    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/us_pc/sm64.us.f3dex2e "$out/bin/sm64ex"
    runHook postInstall
  '';

  meta.description = "Super Mario 64 PC port.";
  passthru.exeName = "sm64ex";
}
