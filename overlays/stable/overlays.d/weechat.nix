# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = {availablePlugins, ...}: {
      scripts = with prev.weechatScripts; [
        autosort
        edit
        url_hint
        wee-slack
        weechat-autosort
        weechat-go
        weechat-notify-send
        zncplayback
      ];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
