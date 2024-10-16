# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

_: prev: rec {
  evdi = prev.linuxPackages_xanmod_latest.evdi.overrideAttrs (
    _final: _prev: rec {
      version = "1.14.7";
      src = prev.fetchFromGitHub {
        owner = "DisplayLink";
        repo = "evdi";
        rev = "refs/tags/v${version}";
        hash = "sha256-z3GawjaokbmmUC1LihwGSnF3tUp9n/FO+kDiWvBq+mY=";
      };
    }
  );

  displaylink = prev.displaylink.override { inherit evdi; };

  sway-unwrapped = prev.sway-unwrapped.override { inherit wlroots; };
  sway = prev.sway.override { inherit sway-unwrapped; };
  wlroots = prev.wlroots_0_17.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ../../patches/wlroots/0001-fix-Patch-backend.c-for-my-use.patch
    ];
  });
}
