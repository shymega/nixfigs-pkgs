# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  goimapnotify =
    prev.goimapnotify.overrideAttrs
    (_oldAttrs: {
      src = prev.fetchFromGitLab {
        owner = "shackra";
        repo = "goimapnotify";
        rev = "4ffe653018b4b295a1ca2634e4108455cb19000a";
        hash = "sha256-fbYujTAU5Vz8DsZQB8TAZYUja92WBK/U/fwgFHQ9TC4=";
      };
    });
}
