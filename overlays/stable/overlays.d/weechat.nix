# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
_: prev: {
  weechat = prev.weechat.overrideAttrs (_: _: {
    version = "unstable";

    src = prev.fetchFromGitHub {
      owner = "shymega";
      repo = "weechat";
      rev = "e9220036278bfdcef798da25576f636abd1215d8";
      hash = "sha256-EQVM3sBkwLXrqPNt6isPkh8yZ7uAFV0+XWdOo+D+LZo=";
    };
  });
}
