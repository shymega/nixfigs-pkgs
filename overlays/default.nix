# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib, inputs, ... }:

let
  importStableOverlay =
    overlay: lib.composeExtensions (_: _: { __inputs = inputs; }) (import (./stable + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable;

  stableOverlaysWithImports = lib.mapAttrs'
    (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = [
    inputs.agenix.overlays.default
    inputs.aimu.overlays.default
    inputs.android-nixpkgs.overlays.default
    inputs.bestool.overlays.default
    inputs.cosmo-codios-codid.overlays.default
    inputs.deckcheatz.overlays.default
    inputs.deskflow.overlays.default
    inputs.dzr-taskwarrior-recur.overlays.default
    inputs.ei-wlroots-proxy.overlays.default
    inputs.emacs2nixpkgs.overlays.default
    inputs.esp32-dev.overlays.default
    inputs.home-statd.overlays.default
    inputs.input-leap.overlays.default
    inputs.nix-alien.overlays.default
    inputs.nixxy-weechat.overlays.default
    inputs.nur.overlay
    inputs.shypkgs-public.overlays.default
    inputs.wemod-launcher.overlays.default
  ] ++ (if inputs.shypkgs-private != null then [ inputs.shypkgs-private.overlays.default ] else [ ]);

  customOverlays = [
    (import ./master.nix { inherit inputs lib; })
    (import ./shymega.nix { inherit inputs lib; })
    (import ./unstable.nix { inherit inputs lib; })
  ];
in
stableOverlaysWithImports
  // {
  default = lib.composeManyExtensions (
    defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
  );
}
