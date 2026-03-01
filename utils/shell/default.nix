{self, ...}: {
  flake.nixosModules.utils-shell = {
    imports = with self.nixosModules; [
      services-fzf
      utils-direnv
      utils-zoxide
    ];
  };
}
