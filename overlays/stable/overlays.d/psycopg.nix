# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  python = prev.python.override {
    packageOverrides = _python-final: python-prev: {
      psycopg = python-prev.psycopg.overrideAttrs (oldAttrs: {
        inherit (oldAttrs) src;
        skipTests = true;
        doCheck = false;
      });
    };
  };
}
