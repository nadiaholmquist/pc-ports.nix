{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "n64recomp";
  version = "0-unstable-2024-08-27";
  src = pkgs.fetchFromGitHub {
    owner = "N64Recomp";
    repo = "N64Recomp";
    rev = "5b17bf8bb556d2544c6161487232a455eae8f188";
    hash = "sha256-4NZzT0Gc/a+thnVljKC7Y+SQPyi4upEiO5qs2wzFYNE=";
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
