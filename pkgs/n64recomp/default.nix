{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "n64recomp";
  version = "0-unstable-2025-02-27";
  src = pkgs.fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "989a86b36912403cd323de884bf834f2605ea770";
    hash = "sha256-DlzqixK8qnKrwN5zAqaae2MoXLqIIIzIkReVSk2dDFg=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = with pkgs; [ cmake ];
  passthru.updateScript = pkgs.unstableGitUpdater {};
  meta = {
    description = "Tool to statically recompile N64 games into native executables";
  };
  buildFlags = ["N64RecompCLI" "RSPRecomp"];
  installPhase = ''
    install -Dm755 N64Recomp $out/bin/N64Recomp
    install -Dm755 RSPRecomp $out/bin/RSPRecomp
  '';
}
