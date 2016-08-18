module Ui.Helpers.Ripple exposing (..)

{-| This is a module for adding a ripple effect to a HTML element.

# View
@docs view
-}

import Html
import Svg.Attributes exposing (cx, cy, r, viewBox)
import Svg exposing (svg, circle)


{-| Renders an SVG element witch a circle for the ripple.

    ripple = Ui.Helpers.Ripple.view
-}
view : Html.Html msg
view =
  svg
    [ viewBox "0 0 100 100"
    ]
    [ circle [ cx "50", cy "50", r "50" ] [] ]
