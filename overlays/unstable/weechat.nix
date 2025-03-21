# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = {availablePlugins, ...}: {
      scripts = let
        weechat-matrix = prev.weechatScripts.weechat-matrix.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            or []
            ++ [
              (prev.fetchpatch {
                url = "https://github.com/poljar/weechat-matrix/pull/349.diff";
                hash = "sha256-tKN+OiYeRAPj4etU7YSoxb8Ezkg8DzYgmfxvCjnuYLI=";
              })
            ];
        });
      in
        with prev.weechatScripts;
          [
            autosort
            edit
            url_hint
            wee-slack
            weechat-autosort
            weechat-go
            weechat-notify-send
            zncplayback
          ]
          ++ [weechat-matrix];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
