# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = {availablePlugins, ...}: {
      scripts = with prev.pkgs.weechatScripts; [
        weechat-notify-send
        weechat-matrix
      ];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
