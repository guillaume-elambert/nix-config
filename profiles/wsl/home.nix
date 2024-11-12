{
  config,
  pkgs,
  userSettings,
  lib,
  ...
}: let
  homeEnv = builtins.getEnv "HOME";
  homeValue =
    if homeEnv != ""
    then homeEnv
    else "/home/" + userSettings.username;

  userFolder = ../../user;
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = homeValue;

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    "${userFolder}/shell/sh/sh.nix" # My zsh and bash config
    "${userFolder}/shell/cli-collection.nix" # Useful CLI apps
    "${userFolder}/shell/ops-collection.nix" # Useful Ops apps
    #../../user/app/doom-emacs/doom.nix # My doom emacs config
    #../../user/app/ranger/ranger.nix # My ranger file manager config
    #../../user/app/git/git.nix # My git config
    #../../user/style/stylix.nix # Styling and themes for my apps
  ];

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Core
    zsh
    git
    syncthing

    # Office
    libreoffice-fresh

    # Various dev packages
    texinfo
    libffi
    zlib
    nodePackages.ungit
  ];

  services.syncthing.enable = true;

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Media/Music";
    videos = "${config.home.homeDirectory}/Media/Videos";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = null;
    publicShare = null;
    extraConfig = {
      #XDG_DOTFILES_DIR = "${config.home.homeDirectory}/.dotfiles";
      XDG_ARCHIVE_DIR = "${config.home.homeDirectory}/Archive";
      #XDG_ORG_DIR = "${config.home.homeDirectory}/Org";
      XDG_BOOK_DIR = "${config.home.homeDirectory}/Media/Books";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  home.sessionVariables = {
    EDITOR = userSettings.editor;
  };

  news.display = "silent";
}
