module Ui.Styles.NumberRange exposing (..)

{-| Styles for a number-range.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input
import Ui.Styles exposing (Style)

{-| Returns the style for a number-range.
-}
style : Style
style =
  [ Mixins.defaults

  , display inlineBlock
  , position relative

  , selectors
    [ "&:before"
    , "&:after"
    ]
    [ pointerEvents none
    , borderStyle solid
    , position absolute
    , marginTop (px -5)
    , contentString ""
    , top (pct 50)
    , opacity 0.5
    , height zero
    , width zero
    , zIndex "1"
    ]

  , selector "&:after"
    [ borderColor (transparent . currentColor . transparent . transparent)
    , borderWidth ((px 5) . (px 6) . (px 5) . zero)
    , left (px 12)
    ]

  , selector "&:before"
    [ borderColor (transparent . transparent . transparent . currentColor)
    , borderWidth ((px 5) . zero . (px 5) . (px 6))
    , right (px 12)
    ]

  , selector "input"
    [ Input.base "ui-number-range"
    , textAlign center
    , zIndex "0"
    ]

  , selector "&:not([readonly]):not([disabled]) input"
    [ cursor (colResize . important)
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-number-range"
