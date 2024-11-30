{ ... }: {
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = ''
        ;; Inspired by https://www.youtube.com/watch?v=sLWQ4Gx88h4 and https://github.com/mhantsch/maxtend/blob/main/kanata/colemax-maxtend.kbd

        ;; Even though I use Colemak as my OS layout, this still has to be defined as qwerty
        (defsrc
          grv 1  2  3  4  5  6  7  8  9  0
          tab  q  w  e  r  t  y  u  i  o  p
          caps  a  s  d  f  g  h  j  k  l  ;
          lsft   z  x  c  v  b  n  m  ,  .

                             spc
        )

        (defvar
          ;; Currently not used
          ;; left-hand-keys (
          ;;   q  w  f  p  b
          ;;    a  r  s  t  g
          ;;      x  c  d  v  z
          ;; )
          ;; right-hand-keys (
          ;;   j  l  u  y  ;  [  ]  \
          ;;    m  n  e  i  o  '
          ;;      k  h  ,  .  /
          ;; )
        )

        (defalias
          ext (layer-while-held navigation)
        )
        (deflayer (default-layer)
          grv 1   2   3   4   5   6   7   8   9   0
          tab  q   w   e   r   t   y   u   i   o   p
          @ext  a   s   d   f   g   h   j   k   l   ;
          lsft   z   x   c   v   b   n   m   ,   .
                                 spc
        )
        ;; I use symbols cause they're not as wide as the text versions.
        ;; See https://github.com/jtroo/kanata/blob/main/docs/fancy_symbols.md
        (deflayer (navigation)
          grv _   _   _   _   _   _   _   _   _   _
          tab  _   _   _   _   _   _   _   _   _   _
          @ext  ‹⎇  ‹❖  ‹⇧  ‹⌃  _   _   ◀   ▲   ▼   ▶
          lsft  C-z C-x  _  C-v C-b  _   ⌫   ⌦   _
                                enter
        )
        ;; Global override to swap shifted state on the number/symbol row 
        (defoverrides
          (1) (lsft 1)
          (2) (lsft 2)
          (3) (lsft 3)
          (4) (lsft 4)
          (5) (lsft 5)
          (6) (lsft 6)
          (7) (lsft 7)
          (8) (lsft 8)
          (9) (lsft 9)
          (0) (lsft 0)

          (lsft 1) (1)
          (lsft 2) (2)
          (lsft 3) (3)
          (lsft 4) (4)
          (lsft 5) (5)
          (lsft 6) (6)
          (lsft 7) (7)
          (lsft 8) (8)
          (lsft 9) (9)
          (lsft 0) (0)
        )
      '';
      extraDefCfg = ''
        process-unmapped-keys no
      '';
    };
  };
}
