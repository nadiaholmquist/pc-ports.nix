{ pkgs, lib, hlsdk-portable, ... }:

pkgs.stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "0-unstable-2025-01-18";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "7811b6029292ccfb665ace25a9c317ddc310e3e9";
    hash = "sha256-aWNHIXJl29dARP98QSFlFOcQYUFMSM1RloXtE68ho3I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    ensureNewerSourcesForZipFilesHook
    pkg-config
    python3
    wafHook
  ];

  buildInputs = (with pkgs; [
    SDL2
    freetype
    fontconfig
  ]) ++ [
    hlsdk-portable
  ];

  # HACK: Remove macOS-specific handling of SDL2 in waf
  # It expects a SDL2.framework, but what Nix provides is a Linux-like file structure instead.
  postPatch = lib.optionalString pkgs.stdenv.isDarwin ''
    substituteInPlace scripts/waifulib/sdl2.py \
      --replace-fail darwin darwin_
  '';

  wafConfigureFlags = ["--64bits" "--enable-packaging" "--prefix=/" ];
  wafInstallFlags = [ "--destdir=${placeholder "out"}" ];

  postInstall = ''
    mv "$out/bin/xash3d" "$out/bin/.xash3d-wrapped"
    substitute ${./wrapper.sh} $out/bin/xash3d \
      --subst-var out \
      --replace-fail /bin/bash ${lib.getExe pkgs.bash}
    chmod +x $out/bin/xash3d
  '';

  postFixup =
    if pkgs.stdenv.isDarwin then ''
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
