{ ... }: {
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = ''
        ;; Inspired by https://www.youtube.com/watch?v=sLWQ4Gx88h4 and https://github.com/mhantsch/maxtend/blob/main/kanata/colemax-maxtend.kbd

        ;; Even though I use Colemak as my OS layout, this still has to be defined as qwerty
        (defsrc
          caps a s d f   j k l ;
        )

        (defvar
          tap-time 200
          hold-time 200
        )

        (defalias
          cap bspc
          ;; Map home row to modifiers
          aM (tap-hold $tap-time $hold-time a lmet)
          sA (tap-hold $tap-time $hold-time s lalt)
          dS (tap-hold $tap-time $hold-time d lsft)
          fC (tap-hold $tap-time $hold-time f lctl)
          jC (tap-hold $tap-time $hold-time j lctl)
          kS (tap-hold $tap-time $hold-time k lsft)
          lA (tap-hold $tap-time $hold-time l lalt)
          ;M (tap-hold $tap-time $hold-time ; lmet)
        )
        (deflayer (default-layer)
          @cap @aM @sA @dS @fC   @jC @kS @lA @;M
        )
      '';
      extraDefCfg = ''
        process-unmapped-keys yes
      '';
    };
  };
}
