final: prev: {
  nix-output-monitor = prev.nix-output-monitor.override {
    extraComposeFunctions = [
      (prev.haskell.lib.compose.appendPatch ./nix-output-monitor-pr321.patch)
    ];
  };

  nh = prev.nh.override {
    inherit (final) nix-output-monitor;
  };
}
