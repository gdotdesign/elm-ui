module Ui.ColorPanel
  (Model, Action, init, update, view, handleMove, handleClick) where

{-| Color panel component for selecting a colors **hue**, **saturation**,
**value** and **alpha** components with draggable interfaces.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs handleMove, handleClick
-}
import Html.Attributes exposing (style, classList)
import Html.Extra exposing (onWithDimensions)
import Html exposing (node, div, text)
import Ext.Color exposing (Hsv)
import Color exposing (Color)

import Ui.Helpers.Drag as Drag

{-| Representation of a color panel:
  - **drag** (internal) - The drag model of the value / saturation rectangle
  - **alphaDrag** (internal) - The drag model of the alpha slider
  - **hueDrag** (internal) - The drag model of the hue slider
  - **value** - The current vlaue
-}
type alias Model =
  { drag : Drag.Model
  , alphaDrag : Drag.Model
  , hueDrag : Drag.Model
  , value : Hsv
  , disabled : Bool
  }

{-| Actions that a color panel can make. -}
type Action
  = LiftAlpha (Html.Extra.DnD)
  | LiftRect (Html.Extra.DnD)
  | LiftHue (Html.Extra.DnD)

{-| Initializes a color panel with the given Elm color.

    ColorPanel.init Color.blue
-}
init : Color -> Model
init color =
  { drag = Drag.init
  , alphaDrag = Drag.init
  , hueDrag = Drag.init
  , value = Ext.Color.toHsv color
  , disabled = False
  }

{-| Updates a color panel. -}
update : Action -> Model -> Model
update action model =
  case action of
    LiftRect {dimensions, position} ->
      { model | drag = Drag.lift dimensions position model.drag }
        |> handleMove (round position.pageX) (round position.pageY)

    LiftAlpha {dimensions, position} ->
      { model | alphaDrag = Drag.lift dimensions position model.alphaDrag }
        |> handleMove (round position.pageX) (round position.pageY)

    LiftHue {dimensions, position} ->
      { model | hueDrag = Drag.lift dimensions position model.hueDrag }
        |> handleMove (round position.pageX) (round position.pageY)

{-| Renders a color panel. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    background =
      "hsla(" ++ (toString (round (model.value.hue * 360))) ++ ", 100%, 50%, 1)"

    color =
      model.value

    colorTransparent =
      (Ext.Color.toCSSRgba { color | alpha = 0 })

    colorFull =
      (Ext.Color.toCSSRgba { color | alpha = 1 })

    gradient =
      "linear-gradient(90deg, " ++ colorTransparent ++ "," ++ colorFull ++ ")"

    asPercent value =
      (toString (value * 100)) ++ "%"
  in
    node "ui-color-panel" [classList [("disabled", model.disabled)]]
      [ div []
        [ node "ui-color-panel-rect"
            [ onWithDimensions "mousedown" True address LiftRect
            , style [ ("background-color", background )
                    , ("cursor", if model.drag.dragging then "move" else "" )
                    ]
            ]
            [ renderHandle
              (asPercent (1 - color.value))
              (asPercent color.saturation) ]
        , node "ui-color-panel-hue"
            [ onWithDimensions "mousedown" True address LiftHue
            , style [("cursor", if model.hueDrag.dragging then "move" else "" )]
            ]
            [ renderHandle (asPercent color.hue) "" ]
        ]
      , node "ui-color-panel-alpha"
        [ onWithDimensions "mousedown" True address LiftAlpha
        , style [("cursor", if model.alphaDrag.dragging then "move" else "" )]
        ]
        [ div [style [("background-image", gradient)]] []
        , renderHandle "" (asPercent color.alpha)
        ]
      ]

{-| Updates a color panel color by coordinates. -}
handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  let
    color =
      if model.drag.dragging then
        handleRect x y model.value model.drag
      else if model.hueDrag.dragging then
        handleHue x y model.value model.hueDrag
      else if model.alphaDrag.dragging then
        handleAlpha x y model.value model.alphaDrag
      else
        model.value
  in
    { model | value = color }

{-| Updates a color panel, stopping the drags if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag
          , alphaDrag = Drag.handleClick value model.alphaDrag
          , hueDrag = Drag.handleClick value model.hueDrag  }

-- Handles the hue drag
handleHue : Int -> Int -> Hsv -> Drag.Model -> Hsv
handleHue x y color drag =
  let
    { top } = Drag.relativePercentPosition x y drag
  in
    { color | hue = clamp 0 1 top }

-- Handles the value / saturation drag
handleRect : Int -> Int -> Hsv -> Drag.Model -> Hsv
handleRect x y color drag =
  let
    { top, left } = Drag.relativePercentPosition x y drag
  in
    { color | saturation = clamp 0 1 left
            , value = 1 - (clamp 0 1 top) }

-- Handles the alpha drag
handleAlpha : Int -> Int -> Hsv -> Drag.Model -> Hsv
handleAlpha x y color drag =
  let
    { left } = Drag.relativePercentPosition x y drag
  in
    { color | alpha = clamp 0 1 left }

-- Renders a handle
renderHandle : String -> String -> Html.Html
renderHandle top left =
  node "ui-color-panel-handle"
    [ style [ ("top", top)
            , ("left", left)
            ]
    ]
    []
