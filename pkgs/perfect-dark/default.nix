{ pkgs, ... }:

let
	bundle = "io.github.fgsfdsfgs.perfect_dark";
in pkgs.pkgsi686Linux.stdenv.mkDerivation (finalAttrs: {
	pname = "perfect-dark";
	version = "1.0-unstable-2024-09-02";

	src = pkgs.fetchFromGitHub {
		owner = "fgsfdsfgs";
		repo = "perfect_dark";
		rev = "2a5c3a351eeb1772306567969fb8dc5b31eaf34e"; 
		hash = "sha256-tpAzpIe2NYUtIY3NsvGl9liOuNb4YQCcfs+oLkFpFQA=";
	};

	patches = [
		./patches/remove-git-usage.patch
	];

	nativeBuildInputs = with pkgs; [
		gnumake
		pkg-config
		python3
	];

	buildInputs = with pkgs.pkgsi686Linux; [
		SDL2
		libGL
		zlib
	];

	enableParallelBuilding = true;
	hardeningDisable = [ "format" ];
	postPatch = ''
		patchShebangs --build .
		substituteInPlace dist/linux/${bundle}.desktop \
			--replace-fail pd perfect-dark
	'';

	makefile = "Makefile.port";
	makeFlags = [
		"GCC_OPT_LVL=-O2"
		"VERSION_HASH=${builtins.substring 0 8 finalAttrs.src.rev}"
		"VERSION_BRANCH=port"
	];

	installPhase = ''
		runHook preInstall
		install -Dm755 build/ntsc-final-port/pd.exe "$out/bin/perfect-dark"
		install -Dm644 dist/linux/${bundle}.desktop "$out/share/applications/${bundle}.desktop"
		install -Dm644 dist/linux/${bundle}.png $out/share/icons/hicolor/256x256/apps/${bundle}.png
		runHook postInstall
	'';

	meta = {
		description = "work in progress port of n64decomp/perfect_dark to modern platforms";
		mainProgram = "perfect-dark";
	};
})
