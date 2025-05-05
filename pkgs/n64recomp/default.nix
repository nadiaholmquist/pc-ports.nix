{
  fetchFromGitHub,
  cmake,
  ninja,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "n64recomp";
  version = "0-unstable-2025-02-27";

  src = fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "989a86b36912403cd323de884bf834f2605ea770";
    hash = "sha256-DlzqixK8qnKrwN5zAqaae2MoXLqIIIzIkReVSk2dDFg=";
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
