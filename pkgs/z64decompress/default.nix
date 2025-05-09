{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "z64decompress";
  version = "1.0.3-unstable-2023-12-21";

  src = fetchFromGitHub {
    owner = "z64utils";
    repo = "z64decompress";
    rev = "e2b3707271994a2a1b3afc6c3997a7cf6b479765";
    hash = "sha256-PHiOeEB9njJPsl6ScdoDVwJXGqOdIIJCZRbIXSieBIY=";
  };

  installPhase = ''
    install -Dm755 z64decompress $out/bin/z64decompress
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Zelda 64 ROM decompressor.";
  };
}
