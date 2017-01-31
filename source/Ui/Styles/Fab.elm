module Ui.Styles.Fab exposing (..)

{-| Styles for a floating action button.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a floating action button using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a floating action button using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , background theme.colors.primary.color
    , color theme.colors.primary.bw

    , cursor pointer

    , justifyContent center
    , alignItems center
    , display flex

    , zIndex theme.zIndexes.fab
    , position absolute
    , bottom (px 30)
    , right (px 30)

    , borderRadius (pct 50)
    , height (px 60)
    , width (px 60)

    , boxShadow
      [ { color = "rgba(0,0,0,0.8)"
        , spread = (px -5)
        , blur = (px 10)
        , inset = False
        , y = (px 5)
        , x = zero
        }
      ]

    , selector "&:hover"
      [ background theme.colors.focus.color
      , color theme.colors.focus.bw
      ]

    , selector "> *"
      [ property "-webkit-filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"
      , property "filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"

      , height (px 24)
      , width (px 24)

      , color currentColor
      , fill currentColor
      ]
    ]
