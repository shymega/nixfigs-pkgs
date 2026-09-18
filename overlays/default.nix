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
    hyprnixOverlaySafe = final: prev: let
      system = prev.stdenv.hostPlatform.system;
      hyprnixPkgs = hyprnix.packages.${system} or {};
      # hyprnix vendors each component (hyprutils, hyprlang, hyprgraphics,
      # aquamarine, hyprcursor, ...) from its own upstream flake, and their
      # nixpkgs pins don't all follow ours: hyprutils/hyprgraphics/
      # aquamarine/hyprcursor/hyprland land on GCC 16 while hyprlang/
      # hypridle/hyprlock stay on GCC 15 (hyprnix's GCC 15->16 bump note),
      # so linking across that split fails with undefined GLIBCXX_3.4.3x
      # references. None of these packages expose their hypr* dependencies
      # as `.override`-able arguments -- passing e.g. `hyprutils = ...` is
      # silently dropped -- so `.override` only fixes the stdenv/compiler;
      # the actual cross-package dependency has to be swapped afterwards
      # via overrideAttrs on buildInputs.
      relink = pkg: replacements: let
        swap = dep: replacements.${lib.getName dep} or dep;
      in
        pkg.overrideAttrs (old: {
          buildInputs = map swap (old.buildInputs or []);
          propagatedBuildInputs = map swap (old.propagatedBuildInputs or []);
        });
      # hyprwm/Hyprland's own flake vendors its own matching
      # xdg-desktop-portal-hyprland and follows one self-consistent nixpkgs
      # throughout, unlike hyprnix's per-component wrapping below -- so
      # source these two straight from hyprnix's `hyprland` subflake input
      # instead, same as the monolith host does.
      rawHyprland = hyprnix.inputs.hyprland.packages.${system} or {};
    in
      hyprnixPkgs
      // lib.optionalAttrs (hyprnixPkgs ? hyprlang) (let
        # hyprlang/hypridle/hyprlock already sit on gcc15Stdenv upstream; every
        # other component here needs pulling onto it explicitly.
        gcc15 = pkg: pkg.override {stdenv = final.gcc15Stdenv;};
        hyprutils = gcc15 hyprnixPkgs.hyprutils;
        patchAquamarine = pkg:
          pkg.overrideAttrs (old: {
            patches = (old.patches or []) ++ [../pkgs/aquamarine/aquamarine-dpms-crtc-churn.patch];
          });
        aquamarine = patchAquamarine (relink (gcc15 hyprnixPkgs.aquamarine) fixed);
        hyprgraphics = relink (gcc15 hyprnixPkgs.hyprgraphics) fixed;
        hyprlang = relink hyprnixPkgs.hyprlang fixed;
        hyprcursor = relink (gcc15 hyprnixPkgs.hyprcursor) fixed;
        hyprpicker = relink (gcc15 hyprnixPkgs.hyprpicker) fixed;
        hypridle = relink hyprnixPkgs.hypridle fixed;
        hyprlock = relink hyprnixPkgs.hyprlock fixed;
        hyprtoolkit = relink (gcc15 hyprnixPkgs.hyprtoolkit) fixed;
        hyprland-guiutils = relink (gcc15 hyprnixPkgs.hyprland-guiutils) fixed;
        hyprpolkitagent = relink (gcc15 hyprnixPkgs.hyprpolkitagent) fixed;
        # every package above is relinked against this one shared set, so
        # each entry must be able to see the others regardless of
        # definition order -- keep it as its own binding rather than
        # inlining per-package replacement maps (which is what caused
        # hyprtoolkit/hyprland-guiutils to keep leaking stale
        # hyprgraphics/aquamarine builds in past iterations of this fix).
        fixed = {inherit hyprutils aquamarine hyprgraphics hyprlang hyprcursor hyprtoolkit;};
        hyprland = rawHyprland.hyprland.override {
          # hyprwm/Hyprland's flake pins its own aquamarine, which lacks
          # the dpms-crtc-churn fix; patch that one too rather than the
          # (differently-built) `aquamarine` above.
          aquamarine = patchAquamarine hyprnix.inputs.hyprland.inputs.aquamarine.packages.${system}.aquamarine;
          # hyprland's CMakeLists.txt requires wayland-protocols >= 1.49,
          # newer than the 1.48 in the top-level nixpkgs pin; pull it from
          # pkgs.unstable rather than bumping the whole tree.
          wayland-protocols = final.unstable.wayland-protocols;
        };
        # xdph's own postInstall wraps hyprland-share-picker with rawHyprland's
        # *unpatched* hyprland on its PATH (baked in as a plain store-path
        # string, not an overridable argument), which drags in the
        # wayland-protocols<1.49 build failure again even though xdph itself
        # never needs to build against it. Swapping the text with
        # lib.replaceStrings isn't enough: Nix string context survives a
        # replace regardless of whether the old text is still present, so
        # the broken hyprland stays a build input unless its context is
        # dropped outright -- then reattached only for what the script
        # actually still references (our fixed hyprland, plus slurp, which
        # has no other formal buildInput and would otherwise be silently
        # unpinned from the store).
        # xdph's own flake.lock pins hyprlang/hyprutils the same way
        # hyprnix's per-component wrapping does (mismatched GCC 15/16), so
        # it needs the same relink treatment as the hyprnix-sourced
        # packages above, on top of the postInstall fix.
        xdg-desktop-portal-hyprland = (relink rawHyprland.xdg-desktop-portal-hyprland fixed).overrideAttrs (old: {
          postInstall =
            builtins.unsafeDiscardStringContext (lib.replaceStrings [rawHyprland.hyprland.outPath] [hyprland.outPath] old.postInstall)
            + "\n: ${hyprland} ${final.slurp}\n";
        });
      in {
        inherit
          hyprutils
          aquamarine
          hyprgraphics
          hyprlang
          hyprcursor
          hyprpicker
          hypridle
          hyprlock
          xdg-desktop-portal-hyprland
          hyprtoolkit
          hyprland-guiutils
          hyprpolkitagent
          hyprland
          ;
      });
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
