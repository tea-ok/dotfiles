{
  # /etc/keyd/default.conf still needs to be applied manually with
  # `sudo stow keyd` until this machine moves to NixOS.
  home.file.".config/niri".source = ../../dotfiles/niri/.config/niri;
}
