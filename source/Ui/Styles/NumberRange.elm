module Ui.Styles.NumberRange exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input

style : Theme -> Node
style theme =
  selector "ui-number-range"
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
      , top (pct 50)
      , opacity 0.5
      , height zero
      , width zero
      , content ""
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
