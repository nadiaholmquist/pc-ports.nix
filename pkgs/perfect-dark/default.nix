{
  cmake,
  fetchFromGitHub,
  lib,
  libGL,
  ninja,
  pkg-config,
  python3,
  SDL2,
  stdenv,
  zlib,
}:

let
  bundle = "io.github.fgsfdsfgs.perfect_dark";
in stdenv.mkDerivation (finalAttrs: {
  pname = "perfect-dark";
  version = "0-unstable-2025-03-30";

  src = fetchFromGitHub {
    owner = "fgsfdsfgs";
    repo = "perfect_dark";
    rev = "0ac5fdd5c3ffc13b453e52dceef6beb219606cc3"; 
    hash = "sha256-+d4N6A00nVViQlzjOq5Ey6aUOQHEhWJhOY8FmIuTkHo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    libGL
    zlib
  ];

  postPatch = ''
    patchShebangs --build tools
    substituteInPlace dist/linux/${bundle}.desktop \
    --replace-fail ${bundle}.sh $out/bin/perfect-dark
  '';

  hardeningDisable = [ "format" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 pd.* "$out/bin/perfect-dark"
    runHook postInstall
  '';

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    install -Dm644 ../dist/linux/${bundle}.desktop -t $out/share/applications/
    install -Dm644 ../dist/linux/${bundle}.png $out/share/icons/hicolor/256x256/apps/${bundle}.png
    install -Dm644 ../dist/linux/${bundle}.metainfo.xml -t $out/share/metainfo/
  '';

  meta = {
    description = "work in progress port of n64decomp/perfect_dark to modern platforms";
    mainProgram = "perfect-dark";
  };
})
