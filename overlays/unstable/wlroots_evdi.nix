# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

_: prev: {

  wlroots_0_17 = prev.wlroots_0_17.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        url = "https://gitlab.freedesktop.org/wlroots/wlroots/uploads/b4f932e370ed03d88f202191eaf60965/DisplayLink.patch";
        hash = "sha256-1HheLsOSnj4OMiA35QCHkWprTNgAeG2tXrGbaQyUrF4=";
      })
    ];
  });
}

