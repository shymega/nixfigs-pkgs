# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{inputs, ...}: final: _prev: {
  shymega = import inputs.nixpkgs-shymega {
    localSystem = final.stdenv.hostPlatform;
    config = inputs.self.nixpkgs-config;
    # overlays = builtins.attrValues shymegaOverlays;
  };
}
