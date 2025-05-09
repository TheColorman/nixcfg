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
          grv 1  2  3  4  5  6  7  8  9  0
          tab  q  w  e  r  t  y  u  i  o  p
          caps  a  s  d  f  g  h  j  k  l  ;
          lsft   z  x  c  v  b  n  m  ,  .  ⁄
          lctl     ‹⎇        spc        ⎇›
        )
        ;; I use symbols cause they're not as wide as the text versions.
        ;; See https://github.com/jtroo/kanata/blob/main/docs/fancy_symbols.md

        ;; This is the setup for using home-row mods. Disabled for now, but I'l
        ;; try it again when I get a split keyboard.
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
          deflt (layer-switch default-layer)
          ralt (multi (one-shot 500 (layer-while-held right-alt))
                                    (one-shot 500 ralt))
          qwerty (layer-switch qwerty)
          numpad (layer-switch numpad)

        )
        (deflayer (default-layer)
          grv 1   2   3   4   5   6   7   8   9   0
          tab  q   w   f   p   b   j   l   u   y   ;
          @ext  a   r   s   t   g   m   n   e   i   o
          lsft   x   c   d   v   z   k   h   ,   .   ⁄
          lctl       ‹⎇           spc          @ralt
        )
        (deflayer (right-alt)
        	_   _   _   _   _   _   _   _   _   _   _
        	_    _   _   _   _   _   _   _   _   _   _
        	@ext  _   _   _   _   _   _   _   _   _   _
        	_      _   _   _   _   _   _   _   _   _   _
        	@qwerty    _             _           @ralt
        )
        (deflayer (navigation)
          grv _   _   _   _   _   _   _   _   _   _
          tab  ⎋   _   _   _   _   _   ⇤   ⇞   ⇟   ⇥
          @ext  ‹⎇  ‹❖  ‹⇧  ‹⌃  _   _   ◀   ▲   ▼   ▶
          lsft  C-x C-c C-d C-v C-z  _   ⌫   ⌦   _   _
          lctl    @numpad    enter               ⎇›
        )
        ;; Since OS already uses colemak-dh, this is essentially a reverse
        ;; mapping back to qwerty
        (deflayer (qwerty)
          grv 1  2  3  4  5  6  7  8  9  0
          tab  q  w  e  r  t  y  u  i  o  p
          caps  a  s  d  f  g  h  j  k  l  ;
          lsft   z  x  c  v  b  n  m  ,  .  ⁄
          lctl     ‹⎇        spc     @deflt
        )
        (deflayer (numpad)
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
