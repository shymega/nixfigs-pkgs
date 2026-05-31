# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  waybar = prev.waybar.overrideAttrs (_finalAttrs: {
    patches = [
      (prev.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/Alexays/Waybar/pull/4982.patch";
        hash = "sha256-acX+MOXN1aSGVA/sK+XEJ/FRAILS1f1JUXm1NHRl45I=";
      })
    ];
  });
}
