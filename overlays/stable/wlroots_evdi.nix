# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

_: prev: rec {
  wlroots-patched = prev.wlroots_0_17.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        url = "https://gitlab.freedesktop.org/wlroots/wlroots/uploads/b4f932e370ed03d88f202191eaf60965/DisplayLink.patch";
        hash = "sha256-1HheLsOSnj4OMiA35QCHkWprTNgAeG2tXrGbaQyUrF4=";
      })
    ];
  });
  sway-unwrapped = prev.sway-unwrapped.override { wlroots = wlroots-patched; };
  sway = prev.sway.override { inherit sway-unwrapped; };
}
