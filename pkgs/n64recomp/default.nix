{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "n64recomp";
  version = "1.0";
  src = pkgs.fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "f8d439aeee6048b7365d1cb3bcd2578ec27a0288";
    hash = "sha256-QiEDSRI9+pRiBA/mx1NTA7uHD6KAEZDP7SaV+FaKsoc";
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
