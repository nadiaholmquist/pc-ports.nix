{ pkgs, hlsdk-portable, waf-setup-hook, ... }:

let
  inherit (pkgs) stdenv;
  gitRev = "e70f9a67b85ef3184f058cd10480d32ef68d14eb";
in stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "unstable-2024-07-26";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = gitRev;
    hash = "sha256-bH2OBnDOztvmfd+UJYeNr2uz1v+xQXGREYmWFRdpC2c";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkgs.ensureNewerSourcesForZipFilesHook
    waf-setup-hook
  ];

  buildInputs = [
    hlsdk-portable
    pkgs.SDL2
  ];

  wafFlags = ["--64bits" "--enable-packaging"];

  fixupPhase = (if stdenv.isDarwin then ''
    runHook preFixup
    install_name_tool "$out/bin/xash3d" \
      -add_rpath "$out/lib/xash3d" \
      -add_rpath "${hlsdk-portable}/valve"
  '' else ''
    patchelf \
      --add-rpath "$out/lib/xash3d:${hlsdk-portable}/valve/dlls:${hlsdk-portable}/valve/cl_dlls" \
      "$out/bin/xash3d"
  '') + ''
    mv "$out/bin/xash3d" "$out/bin/.xash3d-wrapped"
    sed "s|\$out|$out|g" > "$out/bin/xash3d" <<'EOF'
    #!/usr/bin/env bash
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
