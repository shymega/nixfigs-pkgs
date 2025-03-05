# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = {availablePlugins, ...}: {
      scripts = let
        weechat-matrix = prev.pkgs.weechatScripts.weechat-matrix.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            or []
            ++ [
              (prev.pkgs.fetchurl {
                url = "https://github.com/poljar/weechat-matrix/pull/349.diff";
                hash = "sha256-tKN+OiYeRAPj4etU7YSoxb8Ezkg8DzYgmfxvCjnuYLI=";
              })
            ];
        });
      in
        with prev.pkgs.weechatScripts;
          [
            weechat-notify-send
          ]
          ++ [weechat-matrix];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
