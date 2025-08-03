{
  lib,
  makeWrapper,
  stdenv,
  python3,
  requireFile,

  smw,
}:

let
  rom = requireFile rec {
    name = "smas.sfc";
    message = ''
      The ROM ${name} is required to build this package. You can add it to your Nix store with:
        $ nix-store --add-fixed sha256 ${name}
      The hash of the required ROM is:
        ${hash}
    '';
    hash = "sha256-qePlfVkemV6ODdIothm2rtQiBer1Uxb6j/M/I2s6MrM";
  };
in
stdenv.mkDerivation {
  pname = "smb1";
  version = smw.version;

  src = smw.src;
  sourceRoot = "source/other";

  nativeBuildInputs = [
    makeWrapper
    (python3.withPackages (pp: [
      pp.zstandard
    ]))
  ];

  buildPhase = ''
    runHook preBuild
    ln -s ${rom} smas.sfc
    python3 extract.py
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/smw
    install -m644 smb1.sfc -t $out/share/smw
    install -m644 smbll.sfc -t $out/share/smw

    makeWrapper ${lib.getExe smw} $out/bin/smb1 \
      --add-flags $out/share/smw/smb1.sfc
    makeWrapper ${lib.getExe smw} $out/bin/smbll \
      --add-flags $out/share/smw/smbll.sfc
    runHook postInstall
  '';

  meta = smw.meta // {
    description = "Super Mario Bros. and Super Mario Bros. The Lost Levels PC reimplementations";
  };
}
