{
  flake.nixosModules.services-vscode-server = {
    lib,
    pkgs,
    ...
  }: {
    # TODO: figure out how to only define these options if they exist
    wsl.extraBin = [
      {src = lib.getExe' pkgs.coreutils "dirname";}
      {src = lib.getExe' pkgs.coreutils "readlink";}
      {src = lib.getExe' pkgs.coreutils "uname";}
    ];
  };
}
