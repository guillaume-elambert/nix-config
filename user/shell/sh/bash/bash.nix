{
  pkgs,
  config,
  lib,
  custom-lib,
  ...
}: let
  # My shell aliases stored in ./aliases.nix
  myAliases = import ../aliases.nix;

  # Load the bashrc template
  myBashrc = builtins.readFile ./.bashrc;

  # Values to be replaced
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

    # Create an array of values "placeholders.${key}" that has the same lenght of (getKeysToReplace key)
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
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      bashrcExtra = replacePlaceholders {
        str = myBashrc;
        placeholders = placeholders;
      };
    };
  };

  home.file =
    (custom-lib.generateHomeFileEntries ./.bash_completion.d ".bash_completion.d")
    // (custom-lib.generateHomeFileEntries ./.bash_alias ".bash_alias");
}
