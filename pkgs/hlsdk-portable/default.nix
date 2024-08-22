{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "unstable-2024-07-26";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "f1c430ae1d33b946bb86101b806d927d9cf728ad";
    hash = "sha256-Hy2ZdPuTEmBYuhobyluLS/KZx0YFCISY4gQEAroEDmQ";
  };

  nativeBuildInputs = with pkgs; [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
