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
          left-hand-keys (
            q  w  f  p  b
             a  r  s  t  g
               x  c  d  v  z
          )
          right-hand-keys (
            j  l  u  y  ;  [  ]  \
             m  n  e  i  o  '
               k  h  ,  .  /
          )
        )

        (defalias
          cap bspc
          ;; Map home row to modifiers
          aM (multi f24 (tap-hold-release-keys $tap-time $hold-time a lmet $left-hand-keys))
          sA (multi f24 (tap-hold-release-keys $tap-time $hold-time s lalt $left-hand-keys))
          dS (multi f24 (tap-hold-release-keys $tap-time $hold-time d lsft $left-hand-keys))
          fC (multi f24 (tap-hold-release-keys $tap-time $hold-time f lctl $left-hand-keys))
          jC (multi f24 (tap-hold-release-keys $tap-time $hold-time j lctl $right-hand-keys))
          kS (multi f24 (tap-hold-release-keys $tap-time $hold-time k lsft $right-hand-keys))
          lA (multi f24 (tap-hold-release-keys $tap-time $hold-time l lalt $right-hand-keys))
          ;M (multi f24 (tap-hold-release-keys $tap-time $hold-time ; lmet $right-hand-keys))
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
