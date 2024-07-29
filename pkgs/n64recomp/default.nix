{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "n64recomp";
  version = "1.0";
  src = pkgs.fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "ba4aede49c9a5302ecfc1fa599f7acc3925042f9";
    hash = "sha256-9C5mbDlj2gh2hFKm7+UoFLlkzoEzTf6wk5rizzwOUzc=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = with pkgs; [ cmake ];
  passthru.updateScript = pkgs.unstableGitUpdater {};
  meta = {
    description = "Tool to statically recompile N64 games into native executables";
  };
  installPhase = ''
    install -Dm755 N64Recomp $out/bin/N64Recomp
    install -Dm755 RSPRecomp $out/bin/RSPRecomp
  '';
}
