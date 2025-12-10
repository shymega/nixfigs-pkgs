# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Packages for my NixOS Flakes";

  outputs = inputs: let
    inherit (inputs) self;
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = self.nixpkgs-config;
      };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (
      pkgs:
        inputs.nixfigs-helpers.inputs.treefmt-nix.lib.evalModule pkgs inputs.nixfigs-helpers.helpers.formatter
    );

    forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
  in {
    # for `nix fmt`
    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
    # for `nix flake check`
    checks =
      treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs}.config.build.wrapper;
      })
      // forEachSystem (system: {
        pre-commit-check = import "${inputs.nixfigs-helpers.helpers.checks}" {
          inherit self system;
          inherit (inputs.nixfigs-helpers) inputs;
          inherit (inputs.nixpkgs) lib;
        };
      });
    devShells = forEachSystem (
      system: let
        pkgs = genPkgs system;
      in
        import inputs.nixfigs-helpers.helpers.devShells {inherit pkgs self system;}
    );
    nixpkgs-config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      allowBroken = true;
      allowInsecurePredicate = _: true;
    };
    overlays = import ./overlays {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };
    packages = let
      inherit (inputs.nixpkgs.lib) recursiveUpdate;
      zfs-breakpoint-pkgs = {
        "x86_64-linux" = let
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            overlays = builtins.attrValues self.overlays;
          };
        in {
          zfs-breakpoint-hook = pkgs.cachyosKernels.linuxPackages-cachyos-latest.zfs_cachyos.overrideAttrs (_prev: _final: {
            preInstall = ''
              # sleep for 1 hour to force the sandbox to pause
              sleep 3600
            '';
          });
        };
        "aarch64-linux" = {};
      };
      setOne = forEachSystem (
        system: (inputs.shypkgs-private.packages.${system} // inputs.shypkgs-public.packages.${system})
      );
    in
      recursiveUpdate setOne zfs-breakpoint-pkgs;
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-shymega.url = "github:shymega/nixpkgs?ref=shymega/staging";
    nixpkgs-shymega-zfs-bash-fix.url = "github:shymega/nixpkgs?ref=shymega/nixpkgs-unstable-zfs-bash-fix";
    nixfigs-helpers.url = "github:shymega/nixfigs-helpers";
    flake-compat.follows = "nixfigs-helpers/flake-compat";
    agenix.follows = "nixfigs-helpers/agenix";
    nur.url = "github:nix-community/NUR";
    flake-utils.follows = "nixfigs-helpers/flake-utils";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    bestool.url = "github:shymega/bestool?ref=shymega-all-fixes";
    deckcheatz.url = "github:deckcheatz/deckcheatz";
    dzr-taskwarrior-recur.url = "github:shymega/dzr-taskwarrior-recur";
    esp32-dev.url = "github:shymega/esp32-dev.nix";
    shypkgs-private.url = "github:shymega/shypkgs-private";
    shypkgs-public.url = "github:shymega/shypkgs-public";
    xrlinuxdriver = {
      url = "github:shymega/XRLinuxDriver?ref=shymega/nix-flake-support-v2.0.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    devenv.url = "github:cachix/devenv/latest";
  };
}
