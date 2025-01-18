{ stdenv, callPackage }:

callPackage ./generic.nix {
  pname = "smw";
  version = "0.1";
  gameName = "Super Mario World";
  gitRev = "v0.1";
  gitHash = "sha256-n3qkxxwNAKZIiVKs8zIW02O7agbn0DR4P2xBa+Bqfk0";
  romHash = "sha256-CDjlMf4iwHdSj+vhTLP/fEkvH1+o3jVBkr3/cTfCf1s=";
  cflags =
    if stdenv.cc.isClang then
      "-Wno-error=tautological-constant-out-of-range-compare"
    else "";
}
