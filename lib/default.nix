{lib, ...}: let
  # Read all files in the current directory
  files = builtins.readDir ./.;

  # Filter for files with the .nix extension and directories
  nixFilesAndDirs = lib.filter (file: (lib.hasSuffix ".nix" file && file != "default.nix") || files.${file} == "directory") (builtins.attrNames files);

  # Import each Nix file and handle directories
  importedFiles =
    builtins.map (file: import (./. + "/${file}") {inherit lib;})
    nixFilesAndDirs;

  # Merge all imported files into a single set
  importedNixFiles = lib.foldl' (acc: file: acc // file) {} importedFiles;
in
  importedNixFiles
