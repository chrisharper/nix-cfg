{ ssh-key, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "charper+git@charper.co.uk";
    userName = "Chris Harper";
    extraConfig = {
      user = {
        signingkey = "key::${ssh-key}";
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
      };
    };
  };
}
