# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}: let
  importStableOverlay = overlay: lib.composeExtensions (_: _: {__inputs = inputs;}) (import (./stable/enabled.d + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable/enabled.d;

  stableOverlaysWithImports =
    lib.mapAttrs' (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = with inputs; let
    openclawOverlaySafe = final: prev:
    # Only apply when stdenv exists (real nixpkgs, not flake check)
      if prev ? stdenv
      then inputs.nix-openclaw.overlays.default final prev
      else {};
    hyprnixOverlaySafe = _: prev: let
      system = prev.stdenv.hostPlatform.system;
      hyprnixPkgs = hyprnix.packages.${system} or {};
      # Only rescan CRTCs on re-enable, not on disable, so a DPMS-off-induced
      # connector flap doesn't force a full CRTC reassignment/modeset. See
      # pkgs/aquamarine/aquamarine-dpms-crtc-churn.patch.
      aquamarine = hyprnixPkgs.aquamarine.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../pkgs/aquamarine/aquamarine-dpms-crtc-churn.patch];
      });
      # None of these expose aquamarine as an `.override`-able argument, so
      # the patched build has to be swapped in afterwards via overrideAttrs.
      relinkAquamarine = pkg: let
        swap = dep:
          if lib.getName dep == lib.getName aquamarine
          then aquamarine
          else dep;
      in
        pkg.overrideAttrs (old: {
          buildInputs = map swap (old.buildInputs or []);
          propagatedBuildInputs = map swap (old.propagatedBuildInputs or []);
        });
      # hyprnix pins its own nixpkgs (nixos-unstable), which has drifted to
      # glaze 8.x. Hyprland's CMakeLists still find_package()s glaze 7.2.0
      # under CMake's default SameMajorVersion compatibility, so major 8
      # is reported "not found" and the build falls back to a git+network
      # FetchContent that the build sandbox can't perform. nixfigs-pkgs'
      # own nixpkgs pin still has a compatible major-7 glaze, so use that.
      glazeHyprland = prev.glaze.override {
        enableSSL = false;
        enableInterop = false;
      };
    in
      if hyprnixPkgs ? aquamarine
      then
        hyprnixPkgs
        // {
          inherit aquamarine;
          hyprland = relinkAquamarine (hyprnixPkgs.hyprland.override {glaze-hyprland = glazeHyprland;});
          hyprland-guiutils = relinkAquamarine hyprnixPkgs.hyprland-guiutils;
          hyprlauncher = relinkAquamarine hyprnixPkgs.hyprlauncher;
          hyprpaper = relinkAquamarine hyprnixPkgs.hyprpaper;
          hyprpolkitagent = relinkAquamarine hyprnixPkgs.hyprpolkitagent;
          hyprpwcenter = relinkAquamarine hyprnixPkgs.hyprpwcenter;
          hyprshutdown = relinkAquamarine (hyprnixPkgs.hyprshutdown.override {glaze = glazeHyprland;});
          hyprtoolkit = relinkAquamarine hyprnixPkgs.hyprtoolkit;
          xdg-desktop-portal-hyprland = relinkAquamarine hyprnixPkgs.xdg-desktop-portal-hyprland;
        }
      else hyprnixPkgs;
  in [
    agenix.overlays.default
    atuin.overlays.default
    breezy-desktop.overlays.default
    devenv.overlays.default
    dzr-taskwarrior-recur.overlays.default
    hyprnixOverlaySafe
    nix-alien.overlays.default
    nix-cachyos-kernel.overlays.pinned
    nix-doom-emacs-unstraightened.overlays.default
    nur.overlays.default
    openclawOverlaySafe
    shypkgs-public.overlays.default
    waybar.overlays.default
  ];

  customOverlays = [
    (import ./shymega {inherit inputs lib;})
    (import ./unstable {inherit inputs lib;})
  ];
in {
  # Only expose the composed overlay: every consumer applies overlays via
  # `builtins.attrValues self.overlays`, so also exposing the individual
  # stable overlays here would double-apply each of them (already included
  # in `default`) — non-idempotent overlays like nix-output-monitor's patch
  # then fail to apply a second time.
  default = lib.composeManyExtensions (
    defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
  );
}
