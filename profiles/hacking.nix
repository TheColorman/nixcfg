{self, ...}: {
  flake.nixosModules.profiles-hacking = {
    imports = with self.nixosModules; [
      # Networking
      apps-burpsuite
      apps-hashcat
      apps-httptoolkit

      # Android
      apps-apktool
      apps-jadx
      utils-adb
    ];
  };
}
