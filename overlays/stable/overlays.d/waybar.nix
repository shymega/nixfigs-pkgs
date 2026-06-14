# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  waybar-patched = prev.waybar.overrideAttrs (finalAttrs: prevAttrs: {
    patches =
      (prevAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/Alexays/Waybar/pull/5121.patch";
          hash = "sha256-cEcwUL16mJhayeq2fC6EmRyLEGlAXM17yCLjcVGuW14=";
        })
      ];
  });
}
