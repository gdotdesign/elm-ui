module Ui.Styles.DrawerMenu exposing (..)

{-| Styles for a drawer menu.

@docs style
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a drawer menu using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a drawer menu using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ position fixed
    , bottom zero
    , right zero
    , left zero
    , top zero
    , zIndex -1

    , transition
      [ { property = "all"
        , duration = (ms 1)
        , easing = "linear"
        , delay = (ms 320)
        }
      ]

    , selector "&[open]"
      [ zIndex theme.zIndexes.drawer
      , transition
        [ { property = "all"
          , duration = (ms 1)
          , easing = "linear"
          , delay = (ms 0)
          }
        ]

      , selector "ui-drawer-menu-backdrop"
        [ opacity 1
        , transition
          [ { easing = "cubic-bezier(0.215, 0.61, 0.355, 1)"
            , property = "opacity"
            , duration = (ms 320)
            , delay = (ms 0)
            }
          ]
        ]
      , selector "ui-drawer-menu-main"
        [ left zero
        , transition
          [ { easing = "cubic-bezier(0.215, 0.61, 0.355, 1)"
            , duration = (ms 320)
            , property = "left"
            , delay = (ms 0)
            }
          ]
        ]
      ]

    , selector "ui-drawer-menu-backdrop"
      [ background "rgba(0,0,0,0.6)"
      , position absolute
      , bottom zero
      , right zero
      , left zero
      , top zero

      , opacity 0
      , zIndex 0
      , transition
        [ { easing = "cubic-bezier(0.55, 0.055, 0.675, 0.19)"
          , property = "opacity"
          , duration = (ms 320)
          , delay = (ms 0)
          }
        ]
      ]

    , selector "ui-drawer-menu-main"
      [ Mixins.defaults

      , boxShadow
        [ { x = "0"
          , y = "0"
          , blur = px 40
          , spread = "0"
          , color = "rgba(0,0,0,0.2)"
          , inset = False
          }
        ]
      , background theme.colors.primary.color
      , color theme.colors.primary.bw
      , fontFamily theme.fontFamily
      , position absolute
      , minWidth (px 200)
      , left (pct -100)
      , bottom zero
      , top zero
      , zIndex 1

      , transition
        [ { easing = "cubic-bezier(0.55, 0.055, 0.675, 0.19)"
          , duration = (ms 320)
          , property = "left"
          , delay = (ms 0)
          }
        ]
      ]

    , selector "ui-drawer-menu-devider"
      [ borderTop "1px solid rgba(255, 255, 255, 0.2)"
      , margin ((px 10) . zero)
      , display block
      ]

    , selector "ui-drawer-menu-title"
      [ padding ((px 10) . (px 20))
      , fontSize (px 24)
      , display block
      ]

    , selector "ui-drawer-menu-item + ui-drawer-menu-item a"
      [ marginTop (px 5)
      ]

    , selector "ui-drawer-menu-item a"
      [ padding ((px 10) . (px 20))
      , alignItems center
      , fontSize (px 20)
      , display flex

      , selector "&[tabindex]"
        [ cursor pointer
        , outline none

        , selector "&:focus"
          [ background theme.colors.focus.color
          ]
        ]

      , selector "ui-drawer-menu-item-contents"
        [ flex_ "1"
        ]

      , selector "ui-drawer-menu-item-icon"
        [ marginRight (px 15)
        , flex_ "0 0 auto"
        , height (em 1)
        , width (em 1)
        ]

      , selector "svg"
        [ fill currentColor
        , height (em 1)
        , width (em 1)
        ]
      ]
    ]
