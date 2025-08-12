# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  gzdoom = prev.gzdoom.overrideAttrs (_: rec {
    version = "4.11.3";
    src = prev.fetchFromGitHub {
      owner = "ZDoom";
      repo = "gzdoom";
      rev = "g${version}";
      fetchSubmodules = true;
      hash = "sha256-pY+5R3W/9pJGiBoDFkxxpuP0I2ZLb+Q/s5UYU20G748=";
    };
  });
}
