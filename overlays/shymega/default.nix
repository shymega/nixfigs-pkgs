# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  inputs,
  lib,
  ...
}: final: _prev: let
  importShymegaOverlay = overlay: lib.composeExtensions (_: _: {__inputs = inputs;}) (import (./enabled.d + "/${overlay}"));

  shymegaOverlays = lib.mapAttrs' (
    overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importShymegaOverlay overlay)
  ) (builtins.readDir ./enabled.d);
in {
  shymega = import inputs.nixpkgs-shymega {
    localSystem = final.stdenv.hostPlatform;
    config = inputs.self.nixpkgs-config;
    overlays = builtins.attrValues shymegaOverlays;
  };
}
