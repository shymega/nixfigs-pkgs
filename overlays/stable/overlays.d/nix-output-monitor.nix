final: prev: {
  nix-output-monitor = prev.nix-output-monitor.override {
    extraComposeFunctions = [
      (prev.haskell.lib.compose.appendPatch (
        prev.fetchpatch2 {
          url = "https://github.com/maralorn/nix-output-monitor/commit/3c2ae037013e840046ed9785c4da82aa1c628872.patch";
          relative = "nix-output-monitor";
          hash = "sha256-kwmbXQZI+UyOVCAngr6cYpwqIbbG48MJgHzFpCt138o=";
        }
      ))
    ];
  };

  nh = prev.nh.override {
    inherit (final) nix-output-monitor;
  };
}
