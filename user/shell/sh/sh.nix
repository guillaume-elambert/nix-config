{
  pkgs,
  config,
  lib,
  ...
}: let
  # My shell aliases
  myAliases = {
    ls = "eza --icons -l -T -L=1";
    cat = "bat";
    htop = "btm";
    fd = "fd -Lu";
    gitfetch = "onefetch";
    "," = "comma";
  };

  myBashrc = builtins.readFile ./.bashrc;

  placeholders = {
    "BLESH_PATH" = toString pkgs.blesh;
    "ATUIN_PATH" = toString pkgs.atuin;
    "ATUIN_FLAGS" = builtins.warn "${builtins.toJSON (config.programs.atuin.flags or [])}" (lib.escapeShellArgs (config.programs.atuin.flags or [])); # Access the flagsStr attribute
  };

  # Function to replace placeholders with values
  replacePlaceholders = {
    str,
    placeholders,
  }:
    builtins.foldl' (
      acc: key:
        builtins.replaceStrings ["<${key}>"] [placeholders.${key}] acc
    )
    str (builtins.attrNames placeholders);
in {
  home.packages = with pkgs; [
    eza
    bottom
    blesh
    atuin
    bat
    fd
    comma
    onefetch
  ];

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      initExtra = ''
        PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f
         %F{green}→%f "
        RPROMPT="%F{red}▂%f%F{yellow}▄%f%F{green}▆%f%F{cyan}█%f%F{blue}▆%f%F{magenta}▄%f%F{white}▂%f"
        [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '
        bindkey '^P' history-beginning-search-backward
        bindkey '^N' history-beginning-search-forward
      '';
    };

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      bashrcExtra = replacePlaceholders {
        str = myBashrc;
        placeholders = placeholders;
      };
      # blesh.enable = true;
    };

    # blesh = {
    #   enable = true;
    # };

    atuin = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = true;
    };
  };
}
