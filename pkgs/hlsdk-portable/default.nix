{
  fetchFromGitHub,
  python3,
  stdenv,
  wafHook,
}:

stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "0-unstable-2025-09-25";

  src = fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = "5fae1fb3cbfa26991bb592d95b5162cb6de29b83";
    hash = "sha256-l85o3K0jTFQEAjqXug+KDXEJz0u4ZDi7kCBWHd0X7xg=";
  };

  nativeBuildInputs = [
    python3
    wafHook
  ];

  wafConfigureFlags = ["--64bits" "--prefix=/"];
  wafInstallFlags = "--destdir=${placeholder "out"}";
}
