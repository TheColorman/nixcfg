{pkgs, ...}: {
  # Define a user account.
  # Mutable being false means user setup is fully declarative.
  # Removing a user here will also delete the user account.
  users.mutableUsers = false;
  users.users.color = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$GeIykcimY0uMSihQJFxJr.$d98nEQugR8otnw8stez46hw8L2EBnp3lNTJAcen0Q42";
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      google-chrome
      vscode
      vesktop
      neofetch
      #      obsidian
    ];
  };
}
