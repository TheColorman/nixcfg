{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nerd-fonts.caskaydia-cove];
  fonts.packages = with pkgs; [nerd-fonts.caskaydia-cove];
}
