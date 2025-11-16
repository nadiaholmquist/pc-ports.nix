{
  ensureNewerSourcesForZipFilesHook,
  fetchFromGitHub,
  fontconfig,
  freetype,
  lib,
  hlsdk-portable,
  pkg-config,
  python3,
  runtimeShell,
  SDL2,
  stdenv,
  wafHook,
  xorg,
}:

stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "0-unstable-2025-11-16";

  src = fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "1b28d183fca69c289d627c83eeb25d0b07154a9a";
    hash = "sha256-shOS2VNkLlqtgRbaqQu+34PhzKY8OaW7v/xrtEa9yjQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    ensureNewerSourcesForZipFilesHook
    pkg-config
    python3
    wafHook
  ];

  buildInputs = [
    SDL2
    freetype
    fontconfig
    hlsdk-portable
    xorg.libX11
  ];

  # HACK: Remove macOS-specific handling of SDL2 in waf
  # It expects a SDL2.framework, but what Nix provides is a Linux-like file structure instead.
  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace scripts/waifulib/sdl2.py \
      --replace-fail darwin darwin_
  '';

  wafConfigureFlags = ["--64bits" "--enable-packaging" "--prefix=/" ];
  wafInstallFlags = [ "--destdir=${placeholder "out"}" ];

  postInstall = ''
    mv "$out/bin/xash3d" "$out/bin/.xash3d-wrapped"
    substitute ${./wrapper.sh} $out/bin/xash3d \
      --subst-var out \
      --replace-fail /bin/bash ${runtimeShell}
    chmod +x $out/bin/xash3d
  '';

  postFixup =
    if stdenv.isDarwin then ''
      install_name_tool "$out/bin/.xash3d-wrapped" \
        -add_rpath "$out/lib/xash3d" \
        -add_rpath "${hlsdk-portable}/valve"
    '' else ''
      patchelf --add-rpath "$out/lib/xash3d" "$out/bin/.xash3d-wrapped"
      ln -s "${hlsdk-portable}/valve/dlls" "$out/share/xash3d/valve/dlls"
      ln -s "${hlsdk-portable}/valve/cl_dlls" "$out/share/xash3d/valve/cl_dlls"
    '';

  meta = {
    description = "Xash3D FWGS engine.";
    mainProgram = "xash3d";
  };
}
