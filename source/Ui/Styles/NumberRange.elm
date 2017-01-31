module Ui.Styles.NumberRange exposing (..)

{-| Styles for a number-range.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input
import Ui.Styles exposing (Style)

{-| Styles for a number-range using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a number-range using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , Input.inputStyle theme

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
      , zIndex 1
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
      [ textAlign center
      , zIndex 0
      ]

    , selector "&:not([readonly]):not([disabled]) input"
      [ cursor (colResize . important)
      ]
    ]
