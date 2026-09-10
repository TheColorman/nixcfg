{
  flake.nixosModules.services-kanata = {
    services.kanata = {
      enable = true;
      keyboards.default = {
        config = ''
          ;; Inspired by
          ;; https://www.youtube.com/watch?v=sLWQ4Gx88h4
          ;; https://github.com/mhantsch/maxtend/blob/main/kanata/colemax-maxtend.kbd
          ;; https://github.com/DreymaR/BigBagKbdTrixPKL
          (defsrc
            esc
            grv 1  2  3  4  5  6  7  8  9  0  -  =
            tab  q  w  e  r  t  y  u  i  o  p  [  ]
            caps  a  s  d  f  g  h  j  k  l  ;  '
            lsft   z  x  c  v  b  n  m  ,  .  ⁄ rsft
            lctl     ‹⎇        spc        ⎇›
          )
          ;; I use symbols cause they're not as wide as the text versions.
          ;; See https://github.com/jtroo/kanata/blob/main/docs/fancy_symbols.md

          (defalias
            ext (layer-while-held navigation)
            deflt  (layer-switch     default-layer)
            altgr  (layer-while-held alt-graph)
            sftgr  (layer-while-held alt-graph-shift)
            sft    (multi
                     (layer-while-held shift)
                     lsft
                   )
            qwerty (layer-switch     qwerty)
            numpad (layer-while-held numpad)

            ;; Special keys
            æ (unicode æ)
            ø (unicode ø)
            å (unicode å)
            Æ (unicode Æ)
            Ø (unicode Ø)
            Å (unicode Å)

            ⭾ tab
            ⇪⭾ S-tab
          )
          (deflayer (default-layer)
            esc
            grv 1   2   3   4   5   6   7   8   9   0  [  ]
            tab  b   l   d   w   z   '   f   o   u   j  ;  =
            @ext  n   r   t   s   g   y   h   a   e   i  ,
            @sft   q   x   m   c   v   k   p   .   -   ⁄ @sft
            lctl      ‹⎇           spc          @altgr
          )
          (deflayer (shift)
            _
            _  _  _  _  _  _  _  _  _  _  _  _  _ 
            _      _  _  _  _  _  -  _  _  _  _  _  _ 
            _       _  _  _  _  _  _  _  _  _  _  ⁄ 
            _        _  _  _  _  _  _  _  _  '  ,  _ 
            _          _          _         _
          )
          ;; Right-hand mirror layer
          (deflayer (alt-graph)
             _
             _  _   _   _   _   _   _   _   _   _   _   _   _
             _   _   @å  _   @ø  _   z   w   d   l   b   _   _
            @ext  _   _   _   _   _   g   s   t   r   n   _
            @sftgr _   _   _   _   @æ  v   c   m   x   q @sftgr
            @qwerty   _             _           @altgr
          )
          (deflayer (alt-graph-shift)
             _
             _ _   _   _   _   _   _   _   _   _   _   _   _
             _  _   @Å  _   @Ø  _   _   _   _   _   _   _   _ 
            @ext _   _   _   _   _   _   _   _   _   _   _
             _     _   _   _   _   @Æ  _   _   _   _   _  _
             _        _             _           @altgr
          )
          (deflayer (navigation)
            caps
            grv _   _   _   _   _   _   _   _   _   _   _   _
            tab  ⎋  @⇪⭾  @⭾  _   _   ⇤   ⇞   ▲   ⇟   ⇥   _   _
            @ext  ‹⎇  ‹❖  ‹⇧  ‹⌃  _   _   ◀   ▼   ▶   _   _
            lsft  C-x C-c C-d C-v C-z  _   ⌫   ⌦   _   _  rsft
            lctl    @numpad    enter               ⎇›
          )
          ;; Since OS already uses colemak-dh, this is essentially a reverse
          ;; mapping back to qwerty
          (deflayer (qwerty)
            esc
            grv 1  2  3  4  5  6  7  8  9  0  -  =
            tab  q  w  e  r  t  y  u  i  o  p  [  ]
            @ext  a  s  d  f  g  h  j  k  l  ;  '
            lsft   z  x  c  v  b  n  m  ,  .  ⁄ rsft
            lctl     ‹⎇        spc     @deflt
          )
          (deflayer (numpad)
            esc
            grv _   _   _   _   _   _   _   _  kp/ kp*  _   _
            tab  _   _   _   _   _   _   7   8   9  kp-  _   _
            @ext  _   _   _   _   _   _   4   5   6  kp+  _
            lsft   _   _   _   _   _   0   1   2   3  kp. rsft
            lctl     @deflt  NumpadEnter            _
          )
        '';
        extraDefCfg = ''
          process-unmapped-keys no
          ;; windows only i guess
          ;; windows-algr cancel-lctl-press
        '';
      };
    };
  };
}
