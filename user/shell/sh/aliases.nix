let
  aliases = {
    ls = "eza --icons -l -T -L=1";
    ll = "${aliases.ls} -a";
    cat = "bat";
    htop = "btm";
    fd = "fd -Lu";
    gitfetch = "onefetch";
    "," = "comma";
  };
in
  aliases
