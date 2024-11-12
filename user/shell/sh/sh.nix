{
  pkgs,
  config,
  lib,
  ...
}: let
  # My shell aliases stored in ./aliases.nix
  myAliases = import ./aliases.nix;

  # Function to generate home.file entries for each file in a folder, recursively
  generateHomeFileEntries = folder: targetFolder: let
    # Helper function to generate entries for a single file or directory
    generateEntries = file: let
      filePath = "${folder}/${file}";
      targetPath = "${targetFolder}/${file}";
    in
      if files.${file} == "directory"
      then generateHomeFileEntries filePath targetPath
      else {
        "${targetPath}" = {source = filePath;};
      };

    files = builtins.readDir folder;
    # Generate entries for all files and directories in the folder
    entries = builtins.map generateEntries (builtins.attrNames files);
    mergedEntries = lib.foldl' (acc: entry: acc // entry) {} entries;
  in
    mergedEntries;
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

  imports = [
    ./bash/bash.nix
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

  home.file = generateHomeFileEntries ./bin "bin";
}
