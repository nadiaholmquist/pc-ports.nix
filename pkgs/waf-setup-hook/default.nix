{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  name = "waf-setup-hook";
  propagatedBuildInputs = with pkgs; [ python3 ];
  unpackPhase = "true";
  setupHook = ./setup-hook.sh;
}
