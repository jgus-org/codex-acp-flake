{
  description = "ACP adapter for OpenAI Codex";

  inputs = {
    flake-lib.url = "github:jgus-org/flake-lib/v1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      flake-lib,
      nixpkgs,
      ...
    }:
    let
      pin = import ./pin.nix;
      source = {
        owner = "agentclientprotocol";
        repo = "codex-acp";
        type = "github";
      };
    in
    flake-lib.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        orgFormatting = flake-lib.lib.mkFormatting {
          inherit self system;
        };
      in
      {
        checks.formatting = orgFormatting.check;
        formatter = orgFormatting.formatter;
        packages = rec {
          codex-acp = pkgs.buildNpmPackage {
            inherit (pin) npmDepsHash version;
            checkPhase = ''
              npm test -- src/__tests__/CodexACPAgent/CodexAcpClient.test.ts
            '';
            doCheck = true;
            meta = {
              description = "ACP adapter for OpenAI Codex";
              homepage = "https://github.com/agentclientprotocol/codex-acp";
              license = pkgs.lib.licenses.asl20;
              mainProgram = "codex-acp";
            };
            npmBuildScript = "build";
            pname = "codex-acp";
            src = pkgs.fetchFromGitHub {
              inherit (source) owner repo;
              hash = pin.sourceHash;
              rev = pin.sourceRev;
            };
          };
          default = codex-acp;
          update-branches = flake-lib.lib.mkUpdateBranches {
            inherit pkgs source;
            minimumTrackingVersion = "1.7.0";
            pinSchema = "github-npm";
          };
          update-version = flake-lib.lib.mkUpdateVersion {
            inherit pkgs source;
            artifactHook = pkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "codex-acp-release-artifacts";
                runtimeInputs = [
                  pkgs.gh
                  pkgs.prefetch-npm-deps
                ];
                text = ''
                  WORK_DIR="$(mktemp -d)"
                  trap 'rm -rf "''${WORK_DIR}"' EXIT
                  gh api "/repos/''${GH_OWNER}/''${GH_REPO}/contents/package-lock.json?ref=''${NEW_REV}" \
                    -H "Accept: application/vnd.github.raw" > "''${WORK_DIR}/package-lock.json"
                  NPM_DEPS_HASH="$(prefetch-npm-deps "''${WORK_DIR}/package-lock.json")"
                  printf 'npmDepsHash=%s\n' "''${NPM_DEPS_HASH}"
                '';
              }
            );
            extraHashes = [ "npmDepsHash" ];
          };
        };
      }
    );
}
