{
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "price-timeline-card";
  version = "1.3.0-unstable-2026-03-25";

  src = fetchFromGitHub {
    owner = "Neisi";
    repo = "ha-price-timeline-card";
    rev = "09b6c00138d33507ef8f7e5c58a099c4ba31b93c";
    hash = "sha256-+kRmDaF3iEkf2+EbOROPEE64vS9FgJVy0OHqkoZ1CZk=";
  };

  npmDepsHash = "sha256-yyYtCvHMIeq39ytRHOGCZQLdNz+zDzl0QO8A964BIKk=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v ./dist/price-timeline-card.js $out/

    runHook postInstall
  '';

  passthru.entrypoint = "price-timeline-card.js";

  meta = {
    changelog = "https://github.com/Neisi/ha-price-timeline-card/releases/tag/v${version}";
    description = ''
      A custom Home Assistant card that visualizes hourly or 15-minute energy
      prices on a timeline , circle or graph, with color-coded comparison to the
      daily average.
    '';
    homepage = "https://github.com/Neisi/ha-price-timeline-card";
  };
}
