{...}: {
  config = {
    url = {
      "https://github.com/" = {
        insteadOf = [
          "gh:"
          "github:"
        ];
      };
    };
    user = {
      email = "thoren.alex@gmail.com";
      name = "TheColorman";
      signingKey = "3ECF7505E982C8F6";
    };
    commit = {
      gpgsign = true;
    };
  };
}
