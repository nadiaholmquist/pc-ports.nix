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
}:

stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "0-unstable-2025-03-02";

  src = fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "3b51a554dd9764961eff04a9705fbc007807dc85";
    hash = "sha256-lhuQYa4DdYu7XeBkmIt1VGFLM3/TnFSOBjP+0+L1qfs=";
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
