{ callPackage }:

callPackage ./generic.nix {
  pname = "sm";
  version = "0-unstable-2023-04-17";
  gameName = "Super Metroid";
  gitRev = "578f90b3cc49557bb70060ad033bb90b8cf8ac50";
  gitHash = "sha256-5vTxIdDYhnfy73I/okCyNhmaTbfYob+KXTUc8SDQMds";
  romHash = "sha256-Erd8S8nBgyzuiIEkRlkGXuHYTHDD0p5ur5LmeYzCynI";
  binName = "super-metroid";
  cflags = "-Wno-error=pointer-sign";
  linkRom = true;
  linkRomName = "sm.smc";
}
