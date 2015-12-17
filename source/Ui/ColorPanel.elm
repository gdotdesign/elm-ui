module Ui.ColorPanel where

import Html.Attributes exposing (style)
import Html.Extra exposing (onWithDimensions)
import Html exposing (node, div, text)
import Color exposing (Color)
import Ext.Color

import Ui.Helpers.Drag as Drag

type alias Model =
  { drag : Drag.Model
  , alphaDrag : Drag.Model
  , hueDrag : Drag.Model
  , startValue : Color
  , value : Color
  , color : { hue : Float
            , saturation : Float
            , value : Float
            , alpha : Float
            }
  }

type Action
  = LiftRect (Html.Extra.DnD)
  | LiftAlpha (Html.Extra.DnD)
  | LiftHue (Html.Extra.DnD)

checker =
  "url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3wkUCDAEK+8FsQAAADNJREFUKM9jPHPmDAM2YGxsjFWciYFEMKqBGMD4//9/rBJnz54d8p7G5TecGhgZGQfIDwBAQAuAAa2FpwAAAABJRU5ErkJggg==)"

init : Model
init =
  { drag = Drag.init
  , alphaDrag = Drag.init
  , hueDrag = Drag.init
  , startValue = Color.white
  , value = Color.white
  , color = { hue = 0,
              saturation = 1,
              value = 1,
              alpha = 1 }
  }

update : Action -> Model -> Model
update action model =
  case action of
    LiftRect {dimensions, position} ->
      { model | drag = Drag.lift dimensions position model.drag }
    LiftAlpha {dimensions, position} ->
      { model | alphaDrag = Drag.lift dimensions position model.alphaDrag }
    LiftHue {dimensions, position} ->
      { model | hueDrag = Drag.lift dimensions position model.hueDrag }

view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    alphaPosition = model.value
    bg = "hsla(" ++ (toString (round (model.color.hue * 360))) ++ ", 100%, 50%, 1)"
    a = "hsla(" ++ (toString (round (model.color.hue * 360))) ++ ", 100%, 50%, 0)"
    gradient = "linear-gradient(90deg, " ++ a ++ "," ++ bg ++ ")," ++ checker
  in
    node "ui-color-panel" []
      [ div []
        [ node "ui-color-panel-rect"
            [ onWithDimensions "mousedown" False address LiftRect
            , style [("background-color", bg )]
            ]
            []
        , node "ui-color-panel-hue"
            [onWithDimensions "mousedown" False address LiftHue] []
        ]
      , node "ui-color-panel-alpha"
        [ onWithDimensions "mousedown" False address LiftAlpha
        , style [("background-image", gradient)]
        ]
        []
      ]

{-| Updates a number range value by coordinates. -}
handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  let
    color = Ext.Color.toHsv model.value
    (hue, saturation, value) =
      if model.drag.dragging then
        handleRect x y color.hue model
      else if model.hueDrag.dragging then
        handleHue x y color.saturation color.value model
      else
        (color.hue, color.saturation, color.value)
  in
    { model | value = Ext.Color.hsvToRgb { hue = hue, saturation = saturation, value = value, alpha = 1 }
            , color = { hue = hue, saturation = saturation, value = value, alpha = 1} }

handleHue x y saturation value model =
  let
    top = (toFloat y) - model.hueDrag.dimensions.top
    hue = (clamp 0 1 (top / model.hueDrag.dimensions.height))
  in
    (hue, saturation, value)

handleRect x y hue model =
  let
    (top, left) =
      ((toFloat y) - model.drag.dimensions.top, (toFloat x) - model.drag.dimensions.left)
    value = (clamp 0 1 (top / model.drag.dimensions.height))
    saturation = (clamp 0 1 (left / model.drag.dimensions.width))
  in
    (hue, saturation, 1 - value)

{-| Updates a number range, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag
          , alphaDrag = Drag.handleClick value model.alphaDrag
          , hueDrag = Drag.handleClick value model.hueDrag  }

