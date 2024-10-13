{ ... }: {
  networking = {
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "wlp1s0"; # @TODO: infer this? Is this even container related?
      enableIPv6 = true;
    };
    # Prevent networkmanager from managing nix containers
    networkmanager.unmanaged = [ "interface-name:ve-*" ];
  };
}
