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
  sdl2-compat,
  vulkan-loader,
  wrapGAppsHook3,
}:

let
  rom = requireFile rec {
    name = "mk64.us.z64";
    message = ''
      A Mario Kart 64 US ROM is required to build. Dump your ROM and run the following to add it to the Nix store:
       $ nix-store --add-fixed sha256 mk64.us.z64
      The hash of the required ROM is
       ${hash}
    '';
    hash = "sha256-1rhTjdY/ATLssoVufTKBbtPDDj5HmuzSPPg/troXpdo=";
  };

in clangStdenv.mkDerivation {
  pname = "mariokart64recompiled";
  version = "0.9.1";

  src =
    (fetchFromGitHub {
      owner = "sonicdcer";
      repo = "MarioKart64Recomp";
      rev = "8896eb23cd34a57431dffd3cec83a73cf3413922";
      hash = "sha256-VUMKV4A7FpnuSql8iPj2LvBiyUbjJq3GYZ5nVL4lsVI=";
      fetchSubmodules = true;
    })
    # lib/mk64/tools/asm-processor is an ssh URL for some reason
    # https://github.com/NixOS/nixpkgs/issues/195117
    .overrideAttrs (oldAttrs: {
      env = oldAttrs.env or { } // {
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      };
    });

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
    sdl2-compat
    vulkan-loader
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DXC" "dxc")
  ];

  preConfigure = ''
    ln -s "${n64recomp}/bin/N64Recomp" .
    ln -s "${n64recomp}/bin/RSPRecomp" .
    ln -s ${rom} mk64.us.z64
    ./N64Recomp us.toml
    ./RSPRecomp aspMain.us.toml
  '';

  preBuild = ''
    # We need to build patches with unwrapped clang
    # because the parameters passed by NixOS's wrapped clang are incompatible with cross compiling
    make -C ../patches CC="${llvmPackages.clang.cc}/bin/clang" LD=ld.lld
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 MarioKart64Recompiled $out/bin/MarioKart64Recompiled
    mkdir -p "$out/share/MarioKart64Recompiled"
    cp -r ../assets $out/share/MarioKart64Recompiled/assets
    install -Dm644 ../icons/512.png "$out/share/icons/hicolor/512x512/apps/MarioKart64Recompiled.png"
    install -Dm644 ../.github/linux/MarioKart64Recompiled.desktop -t "$out/share/applications"
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --chdir "$out/share/MarioKart64Recompiled"
      --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    )
  '';

  meta = {
    description = "Mario Kart 64: Recompiled game";
    mainProgram = "MarioKart64Recompiled";
    platforms = lib.platforms.linux;
  };
}
