# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  davmail = prev.davmail.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) pname;
    version = "6.3.0";
    rev = 3627;

    src = prev.fetchzip {
      url = "https://ci.appveyor.com/api/projects/mguessan/davmail/artifacts/dist%2Fdavmail-6.3.0-trunk.zip?job=Environment%3A%20JAVA_HOME%3DC%3A%5CProgram%20Files%5CJava%5Cjdk1.8.0";
      hash = "sha256-TJOdwoEdOehy3jxqwGs6FZLVzVZBkRRDFnggjeKOm2k=";
      extension = "zip";
      stripRoot = false;
    };
  });
}
