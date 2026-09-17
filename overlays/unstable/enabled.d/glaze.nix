# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  glaze = prev.glaze.overrideAttrs (_oldAttrs: {
    version = "7.9.1";
    src = prev.fetchFromGitHub {
      owner = "stephenberry";
      repo = "glaze";
      tag = "v7.9.1";
      hash = "sha256-NRRq5MGF2f5PW0teYnq58ELzson+U6KHVPaY6r30KLA=";
    };
  });
}
