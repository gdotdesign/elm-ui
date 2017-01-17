module Ui.Styles.Ripple exposing (style)

import Css exposing (..)

style : Node
style =
  mixin
    [ property "position" "relative"
    , property "overflow" "hidden"
    , selector "&:focus"
      [ selector "svg"
        [ property "transition" "320ms cubic-bezier(0.215, 0.61, 0.355, 1)"
        , property "transform" "scale(1.5)"
        , property "opacity" "0.3"
        ]
      ]
    , selector "&:active"
      [ selector "svg"
        [ property "opacity" "0.6"
        ]
      ]
    , selectors
      [ "&:before", "&:after", "> *" ]
      [ property "position" "relative"
      , property "z-index" "2"
      ]
    , selector "svg"
      [ property "transition" "200ms opacity, 1ms 200ms transform"
      , property "transform-origin" "0 0"
      , property "pointer-events" "none"
      , property "transform" "scale(0)"
      , property "position" "absolute"
      , property "overflow" "visible"
      , property "height" "100%"
      , property "width" "100%"
      , property "z-index" "1"
      , property "opacity" "0"
      , property "left" "50%"
      , property "top" "50%"
      ]
    ]
