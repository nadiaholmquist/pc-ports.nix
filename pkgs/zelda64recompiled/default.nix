{
  clangStdenv,
  cmake,
  directx-shader-compiler,
  fetchFromGitHub,
  gtk3,
  lib,
  lld,
  llvmPackages,
  makeWrapper,
  n64recomp,
  ninja,
  pkg-config,
  requireFile,
  runCommandNoCC,
  SDL2_classic,
  vulkan-loader,
  wrapGAppsHook3,
  z64decompress,
}:

let
  rom = requireFile rec {
    name = "mm.us.rev1.z64";
    message = ''
      A Majora's Mask US ROM is required to build. Dump your ROM and run the following to add it to the Nix store:
       $ nix-store --add-fixed sha256 mm.us.rev1.z64
      The hash of the required ROM is
       ${hash}
    '';
    hash = "sha256-77E2WzrjYmBFFMD5oaLRH13IaIulvmYKN96/XjvkPys=";
  };

  decompressedRom = runCommandNoCC "rom-uncompressed"
    { nativeBuildInputs = [z64decompress]; }
    "z64decompress ${rom} $out";

in clangStdenv.mkDerivation {
  pname = "zelda64recompiled";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Zelda64Recomp";
    repo = "Zelda64Recomp";
    rev = "14f92c41ab116725d14783a3bbd8e53a9cc8e933";
    hash = "sha256-CBD3WMNt/0TZf2e6ku87rr1v2C1ewOOLGxnajGv22bU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set (DXC " "#"
    substituteInPlace lib/rt64/CMakeLists.txt \
      --replace-fail "set (DXC " "#"
  '';

  nativeBuildInputs = [
    makeWrapper
    lld
    cmake
    ninja
    pkg-config
    directx-shader-compiler
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    SDL2_classic
    vulkan-loader
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DXC" "dxc")
  ];

  preConfigure = ''
    ln -s "${n64recomp}/bin/N64Recomp" .
    ln -s "${n64recomp}/bin/RSPRecomp" .
    ln -s ${decompressedRom} mm.us.rev1.rom_uncompressed.z64
    ./N64Recomp us.rev1.toml
    ./RSPRecomp aspMain.us.rev1.toml
    ./RSPRecomp njpgdspMain.us.rev1.toml
  '';

  preBuild = ''
    # We need to build patches with unwrapped clang
    # because the parameters passed by NixOS's wrapped clang are incompatible with cross compiling
    make -C ../patches CC="${llvmPackages.clang.cc}/bin/clang" LD=ld.lld
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 Zelda64Recompiled $out/bin/Zelda64Recompiled
    mkdir -p "$out/share/Zelda64Recompiled"
    cp -r ../assets $out/share/Zelda64Recompiled/assets
    install -Dm644 ../icons/512.png "$out/share/icons/hicolor/512x512/apps/Zelda64Recompiled.png"
    install -Dm644 ../.github/linux/Zelda64Recompiled.desktop -t "$out/share/applications"
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --chdir "$out/share/Zelda64Recompiled"
      --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    )
  '';

  meta = {
    description = "Zelda 64: Recompiled game";
    mainProgram = "Zelda64Recompiled";
    platforms = lib.platforms.linux;
  };
}
