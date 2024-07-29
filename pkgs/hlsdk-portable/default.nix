{ pkgs, waf-setup-hook, ... }:

let
  gitRev = "ce1c96c4b2ac885997fd8f0e5ed6d58b9e90c89c";
in pkgs.stdenv.mkDerivation {
  pname = "hlsdk-portable";
  version = "unstable-2024-07-26";

  src = pkgs.fetchFromGitHub {
    owner = "FWGS";
    repo = "hlsdk-portable";
    rev = gitRev;
    hash = "sha256-ZrZVlzIythYQWGTE96VqBeLGdo4JIQ9+ADvpZgTIGFU";
  };

  nativeBuildInputs = [
    waf-setup-hook
  ];

  wafFlags = ["--64bits"];
}
