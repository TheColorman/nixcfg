{
  description = "Global configuration across systems";

  inputs = {};

  outputs = {...}: {
    config.modules = [ ./configuration.nix ];
  };
}