# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  kanshi = prev.kanshi.overrideAttrs (_oldAttrs: rec {
    version = "unstable";

    src = prev.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "emersion";
      repo = "kanshi";
      rev = "ebfd4de9c23c5f559da2bf72d6d881df7a56c349";
      hash = "sha256-VXTi/ktBVXxCnnnwfvuTN4+n9CbVrG82zdS12yB4CVg=";
    };
  });
}
