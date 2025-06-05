{outputs, ...}: {
  imports = with outputs.modules; [
    # Networking
    apps-burpsuite

    # Android
    apps-apktool
    apps-jadx
    utils-adb
  ];
}
