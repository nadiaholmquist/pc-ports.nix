{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "0-unstable-2025-01-17";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "0dd8f1b148f3afc310e072aec77b28a969562125";
    hash = "sha256-8G+L9EdPSHnQiXbcMSTsHhunzmrsUxqBpr2Kfq320OM=";
  };

  nativeBuildInputs = with pkgs; [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
