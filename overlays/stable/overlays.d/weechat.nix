# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_: prev: {
  weechatWithMyPlugins =
    (prev.weechat.overrideAttrs (_oldAttrs: {
      version = "4.10.0-dev";
      src = prev.fetchFromGitHub {
        owner = "shymega";
        repo = "weechat";
        rev = "cdcdfd7522d0aa723d05447068cbd36a49f6d064";
        hash = "sha256-XNTuyQRH01NDW/lAQsf3gIrGDMhTP9NLL0r5gIO93Qw=";
      };
    })).override {
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
