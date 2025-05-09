{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  console.useXkbConfig = true;
}
