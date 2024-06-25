{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "tmux_session_groups";
}
