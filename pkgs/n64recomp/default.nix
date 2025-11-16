{
  fetchFromGitHub,
  cmake,
  ninja,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "n64recomp";
  version = "0-unstable-2025-10-08";

  src = fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "c39a9b6c7e7596bf8917778d9c15ba78e491b34d";
    hash = "sha256-SpPUXD0zZVcWPgmZnH+5gLDc5qYgGcIhYYtfXKiVAHY=";
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
