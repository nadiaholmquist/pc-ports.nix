{
  fetchFromGitHub,
  cmake,
  ninja,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "n64recomp";
  version = "0-unstable-2026-01-17";

  src = fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "81213c1831fab2521a6a5459c67b63437d67e253";
    hash = "sha256-BfZTmKAXn+9b0lHg0SbTP4/ZTjk7IqvPc78ab8XNFoM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  installPhase = ''
    find . -maxdepth 1 -type f -executable \
      -exec install -Dm755 "{}" -t $out/bin \;
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Tool to statically recompile N64 games into native executables";
  };
}
