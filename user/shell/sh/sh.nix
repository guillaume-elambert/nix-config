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

  myBashrc = builtins.readFile ./bash/.bashrc;

  placeholders = {
    "BLESH_PATH" = toString pkgs.blesh;
    "ATUIN_PATH" = toString pkgs.atuin;
    "ATUIN_FLAGS" = lib.escapeShellArgs (config.programs.atuin.flags or []); # Access the flagsStr attribute
  };

  # Function to replace placeholders with values
  replacePlaceholders = {
    str,
    placeholders,
  }: let
    getKeysToReplace = key: ["\${${key}}" "\$${key}"];

    # Create an array of values "placeholders.${key}"" that has the same lenght of (getKeysToReplace key)
    getValuesToReplace = {
      key,
      keysList ? (getKeysToReplace key),
    }:
      builtins.map (_: placeholders.${key}) keysList;
  in
    builtins.foldl' (
      acc: key: let
        keysList = getKeysToReplace key;
        valuesList = getValuesToReplace {
          key = key;
          keysList = keysList;
        };
      in
        builtins.replaceStrings keysList valuesList acc
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
    oh-my-posh
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
    };

    atuin = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = true;
    };

    oh-my-posh = {
      enable = true;
      useTheme = "powerlevel10k_rainbow";
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
