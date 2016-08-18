module Ui.Helpers.Ripple exposing (..)

import Html

import Svg.Attributes exposing (cx, cy, r, viewBox)
import Svg exposing (svg, circle)

view : Html.Html msg
view =
  svg
    [ viewBox "0 0 100 100"
    ]
    [ circle [cx "50", cy "50", r "50"] [] ]
