{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  name = "copy-rom-hook";
  unpackPhase = "true";
  setupHook = ./setup-hook.sh;
}
