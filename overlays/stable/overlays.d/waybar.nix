# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  waybar-patched = prev.waybar.overrideAttrs (_: _: {
    version = "git";
    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "1471cb26b80b0e61c8081e9145fbcdb2ad22e0d9";
      hash = "sha256-7mQEyyENEH1TNxoB+7oo5ZzDR6n3gKG3QfPU5JO0kvM=";
    };
  });
}
