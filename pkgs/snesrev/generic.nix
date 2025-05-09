{
  fetchFromGitHub,
  python3,
  SDL2,
  requireFile,
  runtimeShell,
  stdenv,

  pname, version,
  gitRev, gitHash, romHash,
  cflags ? "",
  gameName,
  # I feel `sm` is a bit too generic of a name to give a game in $PATH
  binName ? pname,

  linkRom ? false,
  linkRomName ? ""
}:

let
  rom = requireFile {
    name = "${pname}.sfc";
    message = ''
      The ROM "${pname}.sfc" is required to build this package.
      You can add it to your Nix store with:
       $ nix-store --add-fixed sha256 ${pname}.sfc
      The hash of the required ROM is:
       ${romHash}
    '';
    hash = romHash;
  };
  linkAssets = if linkRom then
    "ln -sf ${rom} \"$conf/${linkRomName}\""
  else
    "ln -sf OUT/share/${pname}/${pname}_assets.dat \"$conf/\"";

in stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "snesrev";
    repo = pname;
    rev = gitRev;
    hash = gitHash;
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    (python3.withPackages (py: [
      py.pyyaml
      py.pillow
    ]))
  ];

  buildInputs = [
    SDL2
  ];

  env.NIX_CFLAGS_COMPILE = cflags;

  prePatch = ''
    substituteInPlace Makefile \
      --replace-quiet "/usr/bin/env " ""
  '';

  preBuild = ''
    patchShebangs --build .
    ln -s ${rom} ${pname}.sfc
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 ${pname} "$out/bin/.${pname}-wrapped"
    install -Dm644 ${pname}.ini -t "$out/share/${pname}"
    sed "s|OUT|$out|g" > "$out/bin/${binName}" <<'EOF'
    #!${runtimeShell}
    conf="$HOME/.config/${pname}"
    mkdir -p "$conf"
    cp -n "OUT/share/${pname}/${pname}.ini" "$conf/"
    ${linkAssets}
    cd "$conf"
    exec OUT/bin/.${pname}-wrapped
    EOF
    chmod +x "$out/bin/${binName}"
    runHook postInstall
  '';

  postInstall = if !linkRom then
    "install -Dm644 ${pname}_assets.dat -t \"$out/share/${pname}\""
  else "";

  meta = {
    description = "PC reimplementation of ${gameName}";
    mainProgram = binName;
  };
}
