module Ui.Styles.Fab exposing (..)

{-| Styles for a floating action button.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a floating action button.
-}
style : Style
style =
  [ Mixins.defaults

  , background (varf "ui-fab-background" "colors-primary-background")
  , color (varf "ui-fab-text" "colors-primary-text")

  , cursor pointer

  , justifyContent center
  , alignItems center
  , display flex

  , zIndex (var "ui-fab-z-index" "90")
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
    [ background (varf "ui-fab-hover-background" "colors-focus-background")
    , color (varf "ui-fab-hover-text" "colors-focus-text")
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
  |> mixin
  |> Ui.Styles.attributes "ui-fab"
