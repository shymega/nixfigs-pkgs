# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

_: prev: {
  pmbootstrap-bumped = prev.pmbootstrap.overrideAttrs (oldAttrs: rec {
    version = "3.0.0";

    disabledTests = (oldAttrs.disabledTests or [ ]) ++ [ "test_pkgrepo_pmaports" ];

    doCheck = false;
    doInstallCheck = false;

    src = prev.fetchFromGitLab {
      domain = "gitlab.postmarketos.org";
      owner = "postmarketOS";
      repo = "pmbootstrap";
      rev = version;
      sha256 = "sha256-hUrWMU4V7tf/qVR4geR5FsCQ+BZA+zCPTdCZGN1PMKk=";
    };
  });
}
