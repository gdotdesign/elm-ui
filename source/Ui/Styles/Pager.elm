module Ui.Styles.Pager exposing (..)

{-| Styles for a pager.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a pager using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a pager using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , position relative
    , overflow hidden
    , display block

    , selector "ui-page"
      [ transform [ translate3d zero zero zero ]
      , position absolute
      , width (pct 100)
      , display flex
      , bottom zero
      , top zero

      , selector "> *"
        [ flex_ "1" ]

      , selector "&[animating]"
        [ transition
          [ { easing = "cubic-bezier(0.77, 0, 0.175, 1)"
            , duration = (ms 500)
            , property = "left"
            , delay = (ms 0)
            }
          ]
        ]
      ]
    ]
