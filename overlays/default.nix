# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
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
    in
      if hyprnixPkgs ? aquamarine
      then
        hyprnixPkgs
        // {
          inherit aquamarine;
          hyprland = relinkAquamarine hyprnixPkgs.hyprland;
          hyprland-guiutils = relinkAquamarine hyprnixPkgs.hyprland-guiutils;
          hyprlauncher = relinkAquamarine hyprnixPkgs.hyprlauncher;
          hyprpaper = relinkAquamarine hyprnixPkgs.hyprpaper;
          hyprpolkitagent = relinkAquamarine hyprnixPkgs.hyprpolkitagent;
          hyprpwcenter = relinkAquamarine hyprnixPkgs.hyprpwcenter;
          hyprshutdown = relinkAquamarine hyprnixPkgs.hyprshutdown;
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
in
  stableOverlaysWithImports
  // {
    default = lib.composeManyExtensions (
      defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
    );
  }
