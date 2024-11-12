{lib, ...}: rec {
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
}
