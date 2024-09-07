{ pkgs, lib, hlsdk-portable, ... }:

pkgs.stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "0-unstable-2024-09-05";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "178602ea1fa85f700a2a5873d983162b42b3e9f4";
    hash = "sha256-IVLuZFxJJ+hO/XrdBcEuBb6Nj5SeInFQynFOzwfSq3Q=";
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
    python3 ./waf --version # make waf extract itself
    substituteInPlace .waf3-2.1.2-89fbd1aed01504e28af54a092e4144fb/waflib/extras/sdl2.py \
      --replace-fail darwin darwin_
  '';

  wafConfigureFlags = ["--64bits" "--enable-packaging" "--prefix=/" ];
  wafInstallFlags = [ "--destdir=${placeholder "out"}" ];

  fixupPhase = ''
    runHook preFixup
  '' + (if pkgs.stdenv.isDarwin then ''
    install_name_tool "$out/bin/xash3d" \
      -add_rpath "$out/lib/xash3d" \
      -add_rpath "${hlsdk-portable}/valve"
  '' else ''
    patchelf --add-rpath "$out/lib/xash3d" "$out/bin/xash3d"
    ln -s "${hlsdk-portable}/valve/dlls" "$out/share/xash3d/valve/dlls"
    ln -s "${hlsdk-portable}/valve/cl_dlls" "$out/share/xash3d/valve/cl_dlls"
  '') + ''
    mv "$out/bin/xash3d" "$out/bin/.xash3d-wrapped"
    sed "s|\$out|$out|g" > "$out/bin/xash3d" <<'EOF'
    #! ${lib.getExe pkgs.bash}
    mkdir -p "$HOME/.local/share/xash3d"
    export XASH3D_BASEDIR="''${XASH3D_BASEDIR:-$HOME/.local/share/xash3d}"
    export XASH3D_GAME="''${XASH3D_GAME:-valve}"
    exec "$out/bin/.xash3d-wrapped" -rodir "$out/share/xash3d" "$@"
    EOF
    chmod +x "$out/bin/xash3d"
    runHook postFixup
  '';

  meta = {
    description = "Xash3D FWGS engine.";
    mainProgram = "xash3d";
  };
}
