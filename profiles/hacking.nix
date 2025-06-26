{outputs, ...}: {
  imports = with outputs.modules; [
    # Networking
    apps-burpsuite
    apps-hashcat
    apps-httptoolkit

    # Android
    apps-apktool
    apps-jadx
    utils-adb
  ];
}
