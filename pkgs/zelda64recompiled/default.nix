{ pkgs, lib, z64decompress, n64recomp, ... }:

let
  rom = pkgs.requireFile {
    name = "mm.us.rev1.z64";
    message = ''
      A Majora's Mask US ROM is required to build. Dump your ROM and run the following to add it to the Nix store:
      $ nix-store --add-fixed sha256 mm.us.rev1.z64
    '';
    sha256 = "efb1365b3ae362604514c0f9a1a2d11f5dc8688ba5be660a37debf5e3be43f2b";
  };

  decompressedRom = pkgs.runCommandNoCC "rom-uncompressed"
    { nativeBuildInputs = [z64decompress]; }
    "z64decompress ${rom} $out";

in pkgs.clangStdenv.mkDerivation {
  pname = "zelda64recompiled";
  version = "1.1.1-unstable-2024-08-22";
  src = pkgs.fetchFromGitHub {
    owner = "Zelda64Recomp";
    repo = "Zelda64Recomp";
    rev = "af1404b83d19decbc73364dac233a0ace758e0ca";
    hash = "sha256-E5PdlUjDxviZPPmbl6+lzoT9PvUO2l9qJI4Hj0ePzpg";
    fetchSubmodules = true;
  };

  patches = [
    ./patches/use-packaged-dxc.patch
  ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
    lld
    cmake
    ninja
    pkg-config
    directx-shader-compiler
    wrapGAppsHook3
  ];

  buildInputs = with pkgs; [
    gtk3
    SDL2
    vulkan-loader
  ];

  meta = {
    description = "Zelda 64: Recompiled game";
    mainProgram = "Zelda64Recompiled";
    platforms = lib.platforms.linux;
  };

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
    make -C ../patches CC="${pkgs.llvmPackages.clang.cc}/bin/clang" LD=ld.lld
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
      --prefix LD_LIBRARY_PATH : ${pkgs.vulkan-loader}/lib
    )
  '';
}
