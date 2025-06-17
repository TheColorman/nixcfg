{
  services.znc = {
    enable = true;
    confOptions.passBlock = ''
      <Pass password>
        Method = SHA256
        Hash = a809e85b95ca52efb8c581866d96e8ad67b7e9917e016da154f936499f830d49
        Salt = :5YM*6BBipiTi5yhRRy,
      </Pass>
    '';
  };
}
