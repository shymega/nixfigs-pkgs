# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonApplication rec {
  pname = "totp";
  version = "1.3.0";
  pyproject = true;

  src = fetchPypi {
    pname = "totp";
    inherit version;
    hash = "sha256-reWv3pH1NaO7wKAt4kbfrewKS6RlpZFH4NsYb2ai43I=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [onetimepass];
}
