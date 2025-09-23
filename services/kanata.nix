{
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
          grv 1  2  3  4  5  6  7  8  9  0
          tab  q  w  e  r  t  y  u  i  o  p
          caps  a  s  d  f  g  h  j  k  l  ;
          lsft   z  x  c  v  b  n  m  ,  .  ⁄
          lctl     ‹⎇        spc        ⎇›
        )
        ;; I use symbols cause they're not as wide as the text versions.
        ;; See https://github.com/jtroo/kanata/blob/main/docs/fancy_symbols.md

        ;; This is the setup for using home-row mods. Disabled for now, but
        ;; I'll try it again when I get a split keyboard.
        ;; (defvar
        ;;   left-hand-keys (
        ;;     q  w  f  p  b
        ;;      a  r  s  t  g
        ;;        x  c  d  v  z
        ;;   )
        ;;   right-hand-keys (
        ;;     j  l  u  y  ;  [  ]  \
        ;;      m  n  e  i  o  '
        ;;        k  h  ,  .  /
        ;;   )
        ;; )

        (defalias
          ext (layer-while-held navigation)
          deflt  (layer-switch     default-layer)
          alt    (layer-while-held alt)
          altgr  (layer-while-held alt-graph)
          sftgr  (layer-while-held alt-graph-shift)
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

          ;; Keys that should not be ALT-ed on the ALt layer
          ;x (multi (release-key alt) ;)
          yx (multi (release-key alt) y)
          ux (multi (release-key alt) u)
          lx (multi (release-key alt) l)
          jx (multi (release-key alt) j)
          ox (multi (release-key alt) o)
          ix (multi (release-key alt) i)
          ex (multi (release-key alt) e)
          nx (multi (release-key alt) n)
          mx (multi (release-key alt) m)
          .x (multi (release-key alt) .)
          ,x (multi (release-key alt) ,)
          hx (multi (release-key alt) h)
          kx (multi (release-key alt) k)
          zx (multi (release-key alt) z)
        )
        (deflayer (default-layer)
          esc
          grv 1   2   3   4   5   6   7   8   9   0
          tab  q   w   f   p   b   j   l   u   y   ;
          @ext  a   r   s   t   g   m   n   e   i   o
          lsft   x   c   d   v   z   k   h   ,   .   ⁄
          lctl     @alt           spc          @altgr
        )
        ;; Right-hand mirror layer
        (deflayer (alt)
          _
          _   _   _   _   _   _   _   _   _   _   _
          _   @;x @yx @ux @lx @jx   _   _   _   _  _
          ⌫    @ox @ix @ex @nx  @mx  _   _   _   _   _
          _     @.x @,x @hx @kx   _   _   _   _   _   _
          _        @alt           _            _
        )
        ;; Left-hand mirror layer
        (deflayer (alt-graph)
          _
        	_   _   _      _   _  _   _   _   _   _
        	_    _   @å  _   @ø  _   b   p   f   w   q
        	@ext  _   _   _   _   _   g   t   s   r  a
        	@sftgr _   _   _   _   @æ  v   d   c   x  z
        	@qwerty    _             _           @altgr
        )
        (deflayer (alt-graph-shift)
          _
          _   _   _   _   _   _   _   _      _   _
        	_    _   @Å  _   @Ø  _   _   _   _   _   _
        	@ext  _   _   _   _   _   _   _   _   _   _
        	_      _   _   _   _   @Æ  _   _   _   _   _
        	_          _             _           @altgr
        )
        (deflayer (navigation)
          caps
          grv _   _   _   _   _   _   _   _   _   _
          tab  ⎋  @⇪⭾  @⭾  _   _   _   ⇤   ⇞   ⇟   ⇥
          @ext  ‹⎇  ‹❖  ‹⇧  ‹⌃  _   _   ◀   ▲   ▼   ▶
          lsft  C-x C-c C-d C-v C-z  _   ⌫   ⌦   _   _
          lctl    @numpad    enter               ⎇›
        )
        ;; Since OS already uses colemak-dh, this is essentially a reverse
        ;; mapping back to qwerty
        (deflayer (qwerty)
          esc
          grv 1  2  3  4  5  6  7  8  9  0
          tab  q  w  e  r  t  y  u  i  o  p
          @ext  a  s  d  f  g  h  j  k  l  ;
          lsft   z  x  c  v  b  n  m  ,  .  ⁄
          lctl     ‹⎇        spc     @deflt
        )
        (deflayer (numpad)
          esc
          grv _   _   _   _   _   _   _   _   kp/ kp*
          tab  _   _   _   _   _   _   7   8   9   kp-
          @ext  _   _   _   _   _   _   4   5   6   kp+
          lsft   _   _   _   _   _   0   1   2   3   kp.
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
}
