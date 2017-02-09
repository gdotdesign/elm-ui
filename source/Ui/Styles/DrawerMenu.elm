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

    , selector "ui-drawer-menu-backdrop"
      [ background "rgba(0,0,0,0.6)"
      , position absolute
      , bottom zero
      , right zero
      , left zero
      , top zero
      , zIndex 0
      ]

    , selector "ui-drawer-menu-main"
      [ Mixins.defaults

      , background theme.colors.primary.color
      , color theme.colors.primary.bw
      , position absolute
      , minWidth (px 200)
      , padding (px 20)
      , bottom zero
      , left zero
      , top zero
      , zIndex 1
      ]

    , selector "ui-drawer-menu-close"
      [ background theme.colors.primary.color
      , position absolute
      , display flex
      , justifyContent center
      , alignItems center
      , height (px 40)
      , width (px 40)
      , right (px -40)
      , top (px 0)
      , zIndex 2

      , selector "svg"
        [ fill currentColor
        , height (px 16)
        , width (px 16)
        ]
      ]
    ]
