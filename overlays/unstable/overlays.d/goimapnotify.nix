# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  goimapnotify = prev.goimapnotify.overrideAttrs
    (oldAttrs: {
      src = prev.fetchFromGitLab {
        owner = "shackra";
        repo = "goimapnotify";
        rev = "4ffe653018b4b295a1ca2634e4108455cb19000a";
        hash = "sha256-fbYujTAU5Vz8DsZQB8TAZYUja92WBK/U/fwgFHQ9TC4=";
      };
      patches =
        (oldAttrs.patches or [ ])
        ++ [
          (prev.fetchpatch {
            url = "https://gist.githubusercontent.com/shymega/c6d5701c2d8be448638f59de3842ae33/raw/930d46071c91f2276938505e7d5bb5ea891df850/0001-fix-Disable-Running-commit-messsage.patch";
            sha256 = "sha256-NSjCrjMDT2mpUSeDVFuboowFlMCE9KZYyMj0x/AlY1Y=";
          })
        ];
    });
}
