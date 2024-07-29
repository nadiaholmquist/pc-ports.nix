{ pkgs, lib, hlsdk-portable, ... }:

let
  inherit (pkgs) stdenv;
  gitRev = "dd570b616b3c005b0e78657c1b658612a4463e7f";
in stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "unstable-2024-07-29";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = gitRev;
    hash = "sha256-y6yhAOm4OKoneW2pE8hQ0JMYgksYcczsJ6JvCyZj6l0=";
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

  wafConfigureFlags = ["--64bits" "--enable-packaging" "--prefix=/"];
  dontUseWafInstall = true;

  installPhase = ''
    runHook preInstall
    python3 waf install --destdir="$out"
    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup
  '' + (if stdenv.isDarwin then ''
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
  passthru.exeName = "xash3d";
}
