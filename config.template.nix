{...}: {
  # ---- SYSTEM SETTINGS ---- #
  systemSettings = {
    system = builtins.currentSystem or "x86_64-linux"; # system arch
    profile = "wsl"; # select a profile defined from my "profiles" directory
    timezone = "Europe/Paris"; # select timezone
    locale = "en_US.UTF-8"; # select locale
  };

  # ----- USER SETTINGS ----- #
  userSettings = {
    username = ""; # username
    name = ""; # name/identifier
    email = ""; # email (used for some configurations)
    theme = "io"; # selcted theme from my themes directory (./themes/)
    wm = "hyprland"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
    browser = "brave"; # Default browser; must select one from ./user/app/browser/
    term = "alacritty"; # Default terminal command;
    font = "Intel One Mono"; # Selected font
    fontPkg = "intel-one-mono"; # Font package
    editor = "vim"; # Default editor;
  };
}
