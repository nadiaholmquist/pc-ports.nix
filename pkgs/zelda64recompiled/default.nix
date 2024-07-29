{ pkgs, lib, z64decompress, n64recomp, ... }:

let
  versionNumber = "1.1.1-unstable-2024-07-29";
in pkgs.clangStdenv.mkDerivation {
  pname = "zelda64recompiled";
  version = "${versionNumber}";
  srcs = [
    (pkgs.fetchFromGitHub {
      owner = "Zelda64Recomp";
      repo = "Zelda64Recomp";
      rev = "334640077512b55bdb5dbb2d50ec9ca5403cf240";
      hash = "sha256-cvju+pZZVWWAgoEvgBTHzy1XXWa1780fk7gQfDKUXgc=";
      fetchSubmodules = true;
    })
    (pkgs.requireFile {
      name = "mm.us.rev1.z64";
      message = ''
        A Majora's Mask US ROM is required to build. Dump your ROM and run the following to add it to the Nix store:
        $ nix-store --add-fixed sha256 mm.us.rev1.z64
      '';
      sha256 = "efb1365b3ae362604514c0f9a1a2d11f5dc8688ba5be660a37debf5e3be43f2b";
    })
  ];

  patches = [
    ./patches/use-packaged-dxc.patch
  ];

  nativeBuildInputs = [
    z64decompress
    n64recomp
  ] ++ (with pkgs; [
    makeWrapper
    lld
    cmake
    ninja
    pkg-config
    directx-shader-compiler
    wrapGAppsHook3
  ]);

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

  passthru = {
    updateScript = pkgs.unstableGitUpdater { };
    exeName = "Zelda64Recompiled";
  };

  # Project recommends this, it's also noticeably faster
  cmakeFlags = [ "-GNinja" ];

  preConfigure = ''
    ln -s "${n64recomp}/bin/N64Recomp" .
    ln -s "${n64recomp}/bin/RSPRecomp" .
    ln -s ../mm.us.rev1.rom_uncompressed.z64 .
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
