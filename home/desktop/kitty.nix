{ config, pkgs, ... }:

let
  kittyConfigDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/dotfiles/dotfiles/kitty/.config/kitty"
    else
      "${config.home.homeDirectory}/dotfiles/dotfiles/kitty-nixos/.config/kitty";
in
{
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink kittyConfigDir;
}
