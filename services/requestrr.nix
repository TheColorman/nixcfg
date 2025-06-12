{
  inputs,
  systemPlatform,
  ...
}: {
  imports = [
    inputs.nur.modules.nixos.default
    inputs.nur.legacyPackages."${systemPlatform}".repos.colorman.modules.requestrr
  ];

  services.requestrr.instances.main.enable = true;

  # TODO: Upgrade to a secure version
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];
}
