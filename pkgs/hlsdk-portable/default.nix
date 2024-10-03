{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "unstable-2024-09-25";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "1a29908ead4d76c57896c53cb1b9376edfdd4347";
    hash = "sha256-mL/RsKNoMnVv2P2M+JbvT/7F779w5T6MVXYVTTnHmVs=";
  };

  nativeBuildInputs = with pkgs; [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
