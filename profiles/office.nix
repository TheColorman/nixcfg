{outputs, ...}: {
  imports = with outputs.modules; [
    apps-libreoffice
  ];
}
