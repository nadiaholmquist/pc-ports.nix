{ inputs }: let
  inherit (inputs) nixpkgs systems;
  inherit (nixpkgs.lib) genAttrs mergeAttrsList;
  inherit (nixpkgs.lib.attrsets) mapAttrs filterAttrs;
  inherit (builtins) map filter elem;
  allSystems = import systems;
in {
  mkPackages = sets: genAttrs allSystems (system: mergeAttrsList
    (map (set:
      set.packages {
        inherit system;
        pkgs = (import nixpkgs { inherit system; });
      }
    ) (filter (set: elem system set.systems) sets))
  );

  mkApps = packages: genAttrs allSystems (system: let
    appPkgs = filterAttrs
      (_: pkg: pkg?meta && pkg.passthru?mainProgram )
      packages."${system}";
  in (mapAttrs (_: pkg:
      { type = "app"; program = "${pkg}/bin/${pkg.meta.mainProgram}"; }
    ) appPkgs
  ));
}
