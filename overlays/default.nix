# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  inputs,
  ...
}: let
  importStableOverlay = overlay: lib.composeExtensions (_: _: {__inputs = inputs;}) (import (./stable + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable;

  stableOverlaysWithImports =
    lib.mapAttrs' (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays =
    [
      inputs.agenix.overlays.default
      inputs.aimu.overlays.default
      inputs.android-nixpkgs.overlays.default
      inputs.bestool.overlays.default
      inputs.cosmo-codios-codid.overlays.default
      inputs.deckcheatz.overlays.default
      inputs.deskflow.overlays.default
      inputs.dzr-taskwarrior-recur.overlays.default
      inputs.esp32-dev.overlays.default
      inputs.home-statd.overlays.default
      inputs.input-leap.overlays.default
      inputs.nix-alien.overlays.default
      inputs.nix-doom-emacs-unstraightened.overlays.default
      inputs.nur.overlays.default
      inputs.shypkgs-public.overlays.default
      inputs.wemod-launcher.overlays.default
      inputs.xrlinuxdriver.overlays.default
    ]
    ++ lib.optionals (inputs.shypkgs-private != null) [inputs.shypkgs-private.overlays.default];

  customOverlays = [
    (import ./master.nix {inherit inputs lib;})
    (import ./shymega.nix {inherit inputs lib;})
    (import ./unstable.nix {inherit inputs lib;})
  ];
in
  stableOverlaysWithImports
  // {
    default = lib.composeManyExtensions (
      defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
    );
  }
