{ pkgs, ... }:

let
	gitRev = "b523b1e076158223ff5f07a843522a7898eabb91"; 
	gitShortRev = builtins.substring 0 8 gitRev;
in pkgs.pkgsi686Linux.stdenv.mkDerivation {
	pname = "perfect-dark";
	version = "unstable-2024-05-31";

	src = pkgs.fetchFromGitHub {
		owner = "fgsfdsfgs";
		repo = "perfect_dark";
		rev = gitRev;
		hash = "sha256-GGmmjwIXsxa1yQgXQEQe0C8RWFd5+Jx6BWrXosqIkOQ=";
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
	'';

	makefile = "Makefile.port";
	makeFlags = [
		"GCC_OPT_LVL=-O2"
		"VERSION_HASH=${gitShortRev}"
		"VERSION_BRANCH=port"
	];

	installPhase = ''
		runHook preInstall
		install -Dm755 build/ntsc-final-port/pd.exe "$out/bin/perfect-dark"
		runHook postInstall
	'';

	meta.description = "Perfect Dark PC port.";
	passthru.exeName = "perfect-dark";
}

