{ callPackage }:

callPackage ./generic.nix {
  pname = "zelda3";
  version = "0.3";
  gameName = "The Legend of Zelda: A Link to the Past";
  gitRev = "v0.3";
  gitHash = "sha256-jKCLZ8lqvkN6OmYTZtjxXgbeUUnzOtYaeWmc4rCwwF0";
  romHash = "sha256-ZocdZr4ZrSw0ySfWsUzY62/DGBlltuUXyzYfcxYAnPs=";
  cflags = "-Wno-error=deprecated-non-prototype";
}
