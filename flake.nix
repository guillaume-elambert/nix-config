{
  # Based on https://github.com/librephoenix/nixos-config
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs. (unstable)
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    # Specify the source of Home Manager and Nixpkgs. (stable)
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = inputs @ {self, ...}: let
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      system = builtins.currentSystem or "x86_64-linux"; # system arch
      profile = "wsl"; # select a profile defined from my profiles directory
      timezone = "Europe/Paris"; # select timezone
      locale = "en_US.UTF-8"; # select locale
    };

    # ----- USER SETTINGS ----- #
    userSettings = rec {
      username = "gelambert"; # username
      name = "Guillaume"; # name/identifier
      email = "guillaume.elambert@yahoo.fr"; # email (used for certain configurations)
      theme = "io"; # selcted theme from my themes directory (./themes/)
      wm = "hyprland"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
      # window manager type (hyprland or x11) translator
      wmType =
        if ((wm == "hyprland") || (wm == "plasma"))
        then "wayland"
        else "x11";
      browser = "brave"; # Default browser; must select one from ./user/app/browser/
      spawnBrowser =
        if ((browser == "qutebrowser") && (wm == "hyprland"))
        then "qutebrowser-hyprprofile"
        else
          (
            if (browser == "qutebrowser")
            then "qutebrowser --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=4"
            else browser
          ); # Browser spawn command must be specail for qb, since it doesn't gpu accelerate by default (why?)
      term = "alacritty"; # Default terminal command;
      font = "Intel One Mono"; # Selected font
      fontPkg = "intel-one-mono"; # Font package
      editor = "vim"; # Default editor;

      # editor spawning translator
      # generates a command that can be used to spawn editor inside a gui
      # EDITOR and TERM session variables must be set in home.nix or other module
      # I set the session variable SPAWNEDITOR to this in my home.nix for convenience
      spawnEditor =
        if (editor == "emacsclient")
        then "emacsclient -c -a 'emacs'"
        else
          (
            if
              ((editor == "vim")
                || (editor == "nvim")
                || (editor == "nano"))
            then "exec " + term + " -e " + editor
            else
              (
                if (editor == "neovide")
                then "neovide -- --listen /tmp/nvimsocket"
                else editor
              )
          );
    };

    useStable = (systemSettings.profile == "homelab") || (systemSettings.profile == "worklab");

    # use nixpkgs if running a server (homelab or worklab profile)
    # otherwise use nixos-unstable nixpkgs
    nixpkgs =
      if useStable
      then builtins.warn "stable: ${inputs.nixpkgs-stable}" inputs.nixpkgs-stable
      else builtins.warn "unstable: ${inputs.nixpkgs}" inputs.nixpkgs;

    lib = nixpkgs.lib;

    pkgs = import nixpkgs {
      system = systemSettings.system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    # use home-manager-stable if   running a server (homelab or worklab profile)
    # otherwise use home-manager-unstable
    home-manager =
      if useStable
      then builtins.warn "stable home-manager: ${inputs.home-manager-stable}" inputs.home-manager-stable
      else builtins.warn "unstable home-manager: ${inputs.home-manager-unstable}" inputs.home-manager-unstable;
  in {
    homeConfigurations = {
      user = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix") # load home.nix from selected PROFILE
        ];
        extraSpecialArgs = {
          # pass config variables from above
          inherit systemSettings;
          inherit userSettings;
          inherit inputs;
        };
      };
    };
  };
}
