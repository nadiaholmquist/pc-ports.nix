{
  clangStdenv,
  cmake,
  directx-shader-compiler,
  fetchFromGitHub,
  gtk3,
  lib,
  lld,
  n64recomp,
  ninja,
  pkg-config,
  requireFile,
  rustPlatform,
  sdl2-compat,
  vulkan-loader,
  wrapGAppsHook3,
}:

let
  rom = requireFile rec {
    name = "banjo.us.v10.z64";
    message = ''
      A Banjo-Kazooie US 1.0 ROM is required to build. Dump your ROM and run the following to add it to the Nix store:
       $ nix-store --add-fixed sha256 banjo.us.v10.z64
      The hash of the required ROM is
       ${hash}
    '';
    hash = "sha256-WYdYNbmlEouwBUMVp/kp4gccIAHlKNcL9UPh1mgObv8=";
  };

in clangStdenv.mkDerivation (finalAttrs: {
  pname = "banjorecomp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "BanjoRecomp";
    repo = "BanjoRecomp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QIiSjwA0iyoGTaeKANah6WhTUwPGXv1qR26kTdg7OqU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set (DXC " "#"
    substituteInPlace lib/rt64/CMakeLists.txt \
      --replace-fail "set (DXC " "#"
  '';

  nativeBuildInputs = [
    lld
    cmake
    ninja
    pkg-config
    directx-shader-compiler
    wrapGAppsHook3
    finalAttrs.bk_rom_compressor
  ];

  buildInputs = [
    gtk3
    sdl2-compat
    vulkan-loader
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DXC" "dxc")

    # We need to build patches with unwrapped clang
    # because the parameters passed by NixOS's wrapped clang are incompatible with cross compiling
    (lib.cmakeFeature "PATCHES_C_COMPILER" (lib.getExe clangStdenv.cc.cc))
    (lib.cmakeFeature "PATCHES_LD" "ld.lld")
  ];

  bk_rom_compressor = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "bk_rom_compressor";
    version = "0-unstable-2024-09-08";

    src = fetchFromGitHub {
      owner = "MittenzHugg";
      repo = "bk_rom_compressor";
      rev = "272180b527b01c0023dc2ab02bdfdfd373670906";
      hash = "sha256-lnmnoomJTy8lAjoUjXvkXWFnf9LGtAGcD4WNFTDkiPk=";
      fetchSubmodules = true;
    };

    preBuild = ''
      mkdir rarezip/c
      NIX_CFLAGS_COMPILE="-std=c99 -D_BSD_SOURCE" make -C rarezip c
    '';

    cargoHash = "sha256-JxK2S0JTBepT8nTTlBsZlS9+NvL+/rIRPmreX1Kmat4=";
  });

  preConfigure = ''
    bk_rom_decompress ${rom} banjo.us.v10.decompressed.z64
    ln -s "${n64recomp}/bin/N64Recomp" .
    ln -s "${n64recomp}/bin/RSPRecomp" .
    ./N64Recomp banjo.us.rev0.toml
    ./RSPRecomp n_aspMain.us.rev0.toml
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 BanjoRecompiled $out/bin/BanjoRecompiled
    install -Dm644 ../recompcontrollerdb.txt -t $out/share/BanjoRecompiled
    cp -r ../assets $out/share/BanjoRecompiled/assets
    install -Dm644 ../icons/app.png "$out/share/icons/hicolor/512x512/apps/BanjoRecompiled.png"
    install -Dm644 ../.github/linux/BanjoRecompiled.desktop -t "$out/share/applications"
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --chdir "$out/share/BanjoRecompiled"
      --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    )
  '';

  meta = {
    description = "Banjo: Recompiled game";
    mainProgram = "BanjoRecompiled";
    platforms = lib.platforms.linux;
  };
})
