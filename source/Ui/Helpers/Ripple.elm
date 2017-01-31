module Ui.Helpers.Ripple exposing (..)

{-| This is a module for adding a ripple effect to an HTML element.

# View
@docs view
-}

import Svg.Attributes exposing (r)
import Svg exposing (svg, circle)

import Html.Attributes exposing (attribute)
import Html

{-| Renders an SVG element witch a circle for the ripple.

    ripple = Ui.Helpers.Ripple.view
-}
view : Html.Html msg
view =
  svg
    [ attribute "ripple" "" ]
    [ circle [ r "75%" ] [] ]
