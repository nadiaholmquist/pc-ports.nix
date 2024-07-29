wafConfigurePhase() {
	runHook preConfigure
	./waf configure -T release --prefix=/ $wafFlags
	runHook postConfigure
}

wafBuildPhase() {
	runHook preBuild
	./waf
	runHook postBuild
}

wafInstallPhase() {
	runHook preInstall
	./waf install --destdir="$out"
	runHook postInstall
}

configurePhase=wafConfigurePhase
buildPhase=wafBuildPhase
installPhase=wafInstallPhase
