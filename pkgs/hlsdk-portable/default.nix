{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "0-unstable-2025-02-24";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "06a3cae8a7f0d3d5477bd71aefaa68f74856b316";
    hash = "sha256-DvXdRU3JczE72+bt8T8BugL5sGhIPbvA74UQVsrmXhI=";
  };

  nativeBuildInputs = with pkgs; [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
