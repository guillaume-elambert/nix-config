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
    # Import configuration from ./config.nix and get the 2 variables `systemSettings` and `userSettings`
    config = import ./config.nix {inherit inputs;};
    systemSettings = config.systemSettings;
    userSettings =
      config.userSettings
      // {
        # window manager type (hyprland or x11) translator
        wmType =
          if ((config.userSettings.wm == "hyprland") || (config.userSettings.wm == "plasma"))
          then "wayland"
          else "x11";
        spawnBrowser =
          if ((config.userSettings.browser == "qutebrowser") && (config.userSettings.wm == "hyprland"))
          then "qutebrowser-hyprprofile"
          else
            (
              if (config.userSettings.browser == "qutebrowser")
              then "qutebrowser --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=4"
              else config.userSettings.browser
            ); # Browser spawn command must be specail for qb, since it doesn't gpu accelerate by default (why?)

        # editor spawning translator
        # generates a command that can be used to spawn editor inside a gui
        # EDITOR and TERM session variables must be set in home.nix or other module
        # I set the session variable SPAWNEDITOR to this in my home.nix for convenience
        spawnEditor =
          if (config.userSettings.editor == "emacsclient")
          then "emacsclient -c -a 'emacs'"
          else
            (
              if
                ((config.userSettings.editor == "vim")
                  || (config.userSettings.editor == "nvim")
                  || (config.userSettings.editor == "nano"))
              then "exec " + config.userSettings.term + " -e " + config.userSettings.editor
              else
                (
                  if (config.userSettings.editor == "neovide")
                  then "neovide -- --listen /tmp/nvimsocket"
                  else config.userSettings.editor
                )
            );
      };

    useStable = (systemSettings.profile == "homelab") || (systemSettings.profile == "worklab");

    # use nixpkgs if running a server (homelab or worklab profile)
    # otherwise use nixos-unstable nixpkgs
    nixpkgs =
      if useStable
      then inputs.nixpkgs-stable
      else inputs.nixpkgs;

    lib = nixpkgs.lib;
    custom-lib = import ./lib {inherit lib;};

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
      then inputs.home-manager-stable
      else inputs.home-manager-unstable;
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
          inherit custom-lib;
        };
      };
    };
  };
}
