{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  requests,
  python-dotenv,
}:

buildPythonPackage {
  pname = "electricity-cost-dkk";
  version = "0.1.1";

  pyproject = true;

  src = fetchPypi {
    pname = "electricity_cost_dkk";
    version = "0.1.1";
    hash = "sha256-Cg1XsUznAsWCAE/Pjv2A4pC2YXkbMciG4GwY69miQcw=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    python-dotenv
  ];

  meta = {
    description = "Combines spot prices, grid tariffs, and provider markup to calculate Danish electricity costs";
    homepage = "https://github.com/victorfaurschou/electricity-cost-dkk";
    license = lib.licenses.mit;
  };
}
