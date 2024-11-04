{pkgs, ...}: {
  # Collection of useful CLI apps
  home.packages = with pkgs; [
    killall
    gnugrep
    neovim
  ];
}
