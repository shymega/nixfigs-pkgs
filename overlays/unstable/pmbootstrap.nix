# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  pmbootstrap-bumped = prev.pmbootstrap.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) src version pname;

    disabledTests = (oldAttrs.disabledTests or []) ++ ["test_pkgrepo_pmaports"];

    doCheck = false;
    doInstallCheck = false;
  });
}
