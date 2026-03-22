{
  description = "SALT - Software And License Taxonomy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , treefmt-nix
    , git-hooks
    , ...
    }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs supportedSystems;

      treefmtEval = forAllSystems (system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );

      # ── Load checked-in taxonomy data ──────────────────────────────
      index = builtins.fromJSON (builtins.readFile ./data/_index.json);

      # Load all per-license JSON files from data/licenses/
      # Keys are ScanCode LicenseDB identifiers
      licenseFiles = builtins.attrNames (builtins.readDir ./data/licenses);
      licenses = builtins.listToAttrs (map
        (f:
          let
            key = lib.removeSuffix ".json" f;
            data = builtins.fromJSON (builtins.readFile (./data/licenses + "/${f}"));
          in
          { name = key; value = data; })
        licenseFiles);

      # Secondary index by SPDX identifier (~786 of 2649 have SPDX IDs)
      spdx = builtins.listToAttrs (builtins.filter (e: e != null) (map
        (entry:
          if entry.spdx != null && entry.spdx != "" && !(lib.hasPrefix "LicenseRef-" entry.spdx) then
            { name = entry.spdx; value = licenses.${entry.key}; }
          else null)
        index.licenses));

    in
    {
      inherit licenses spdx;
      inherit (index) meta;

      # Formatter
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      # Checks
      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkNixTest = name: results:
            let
              allValues = builtins.attrValues results;
              allPass = builtins.all (x: x) allValues;
              count = builtins.length allValues;
            in
            assert allPass;
            pkgs.runCommand "salt-test-${name}" { } ''
              echo "${name}: ${toString count} tests passed"
              echo "${name}: ${toString count} tests passed" > $out
            '';
        in
        {
          formatting = treefmtEval.${system}.config.build.check self;

          pre-commit = git-hooks.lib.${system}.run {
            src = self;
            hooks = {
              treefmt = {
                enable = true;
                package = treefmtEval.${system}.config.build.wrapper;
              };
              statix.enable = true;
              deadnix.enable = true;
            };
          };

          taxonomy = mkNixTest "taxonomy"
            (import ./tests/taxonomy.nix { inherit (self) licenses spdx meta; });

          # Verify SHA-256 integrity of every license file
          integrity = pkgs.runCommand "salt-integrity-check"
            {
              nativeBuildInputs = [ pkgs.jq ];
            } ''
            PASS=0
            FAIL=0
            for f in ${self}/data/licenses/*.json; do
              key=$(jq -r '.key' "$f")
              stored=$(jq -r '.integrity.digest' "$f")
              computed=$(jq -cS 'del(.integrity)' "$f" | sha256sum | cut -d' ' -f1)
              if [ "$stored" = "$computed" ]; then
                PASS=$((PASS + 1))
              else
                echo "INTEGRITY FAIL: $key (stored=$stored computed=$computed)"
                FAIL=$((FAIL + 1))
              fi
            done
            if [ "$FAIL" -gt 0 ]; then
              echo "$FAIL integrity failures"
              exit 1
            fi
            echo "$PASS licenses verified"
            echo "$PASS licenses verified" > $out
          '';
        }
      );

      # Dev shell
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (self.checks.${system}) pre-commit;
        in
        {
          default = pkgs.mkShell {
            inherit (pre-commit) shellHook;
            buildInputs = pre-commit.enabledPackages ++ [
              pkgs.statix
              pkgs.deadnix
              pkgs.nixpkgs-fmt
              pkgs.jq
            ];
          };
        }
      );
    };
}
