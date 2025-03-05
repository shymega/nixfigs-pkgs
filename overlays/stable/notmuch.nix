# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  notmuch = prev.notmuch.overrideAttrs (_oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
  });
}
