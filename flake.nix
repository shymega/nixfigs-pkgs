# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk

#
# SPDX-License-Identifier: GPL-3.0-only

{
  description = "Packages for my NixOS Flakes";

  nixConfig = {
    extra-trusted-substituters = [
      "https://attic.mildlyfunctional.gay/nixbsd"
      "https://cache.dataaturservice.se/spectrum/"
      "https://cache.nixos.org/"
      "https://deckcheatz-nightlies.cachix.org"
      "https://cache.saumon.network/proxmox-nixos"
      "https://deploy-rs.cachix.org/"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://numtide.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "deckcheatz-nightlies.cachix.org-1:ygkraChLCkqqirdkGjQ68Y3LgVrdFB2bErQfj5TbmxU="
      "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
      "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nixbsd:gwcQlsUONBLrrGCOdEboIAeFq9eLaDqfhfXmHZs1mgc="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
    ];
  };

  outputs =
    inputs:
    let
      inherit (inputs) self;
      genPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
          config = self.nixpkgs-config;
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
      treeFmtEval = treeFmtEachSystem (pkgs: inputs.nixfigs-helpers.inputs.treefmt-nix.lib.evalModule pkgs inputs.nixfigs-helpers.helpers.formatter);

      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
      forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;
    in
    {
      libx = forAllSystems
        (system:
          inputs.helpers.libx.${system});
      overlays = import ./overlays { inherit inputs; inherit (inputs.nixpkgs) lib; };
      # for `nix fmt`
      formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks =
        treeFmtEachSystem
          (pkgs: {
            formatting = treeFmtEval.${pkgs}.config.build.wrapper;
          })
        // forEachSystem (system: {
          pre-commit-check = import "${inputs.nixfigs-helpers.helpers.checks}" {
            inherit
              self
              system;
            inherit (inputs.nixfigs-helpers) inputs;
            inherit (inputs.nixpkgs) lib;
          };
        });
      devShells = forEachSystem (
        system:
        let
          pkgs = genPkgs system;
        in
        import inputs.nixfigs-helpers.helpers.devShells { inherit pkgs self system; }
      );
      nixpkgs-config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
        allowBroken = true;
        allowInsecurePredicate = _: true;
      };
      packages =
        forEachSystem (system:
          (inputs.shypkgs-private.packages.${system} // inputs.shypkgs-public.packages.${system}));
    };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs/shymega/staging";
    nixfigs-helpers.url = "github:shymega/nixfigs-helpers";
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nur.url = "github:nix-community/NUR";
    flake-utils.url = "github:numtide/flake-utils";
    aimu.url = "github:shymega/aimu/refactor-shymega";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-index-database.follows = "nix-index-database";
      };
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bestool.url = "github:shymega/bestool/shymega-all-fixes";
    deckcheatz.url = "github:deckcheatz/deckcheatz/develop";
    dzr-taskwarrior-recur.url = "github:shymega/dzr-taskwarrior-recur";
    emacs2nixpkg.url = "github:shymega/emacs2nixpkg";
    cosmo-codios-codid.url = "github:cosmo-codios/codid";
    ei-wlroots-proxy.url = "github:input-leap/ei-wlroots-proxy";
    input-leap-shymega.url = "github:shymega/input-leap/feature/nix-support";
    wemod-launcher.url = "github:shymega/wemod-launcher/refactor-shymega";
    shypkgs-private.url = "github:shymega/shypkgs-private";
    shypkgs-public.url = "github:shymega/shypkgs-public";
    home-statd.url = "github:shymega/home-statd";
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";
  };
}
