{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "unstable-2024-11-07";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "82f85a4a6e963e16f732a8eca900592ed8a6b3c5";
    hash = "sha256-CdIW9fx7nTP0sPupmbsIr8GuHEiONc1engJpNQ7DxpE=";
  };

  nativeBuildInputs = with pkgs; [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
