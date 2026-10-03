{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  callPackage,
}:
let
  electricity-cost-dkk = callPackage ./electricity-cost-dkk.nix { };
in

buildHomeAssistantComponent {
  owner = "victorfaurschou";
  domain = "electricity_costs_dkk";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "victorfaurschou";
    repo = "ha-electricity-costs-dkk";
    rev = "2bd0f1d";
    hash = "sha256-gDqcfUPQ3h3J8o5XbTZsRKUTdTkgzImc2Cs4Ibp/WxA=";
  };

  postPatch = ''
    find custom_components/electricity_costs_dkk -type f -name '*.py' \
      -exec sed -i \
        -e 's/from electricity_costs_dkk/from electricity_cost_dkk/g' \
        -e 's/import electricity_costs_dkk/import electricity_cost_dkk/g' \
        {} +

    substituteInPlace custom_components/electricity_costs_dkk/manifest.json \
      --replace-fail \
        '"electricity-costs-dkk==0.1.0"' \
        '"electricity-cost-dkk==0.1.1"'
  '';

  dependencies = [
    electricity-cost-dkk
  ];

  ignoreVersionRequirement = [
    "electricity-costs-dkk"
  ];

  meta = {
    description = "Home Assistant integration for Danish electricity costs";
    homepage = "https://github.com/victorfaurschou/ha-electricity-costs-dkk";
    license = lib.licenses.mit;
  };
}
