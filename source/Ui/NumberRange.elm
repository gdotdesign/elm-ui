module Ui.NumberRange where

import Html.Events exposing (onFocus, onBlur)
import Html.Extra exposing (onWithDimensions, onKeys, onInput, onStop)
import Html.Attributes exposing (value, contenteditable)
import Html exposing (node, text, input)
import Number.Format exposing (pretty)
import Native.Browser
import Json.Decode as Json
import Result
import String

import Ui.Helpers.Drag as Drag

import Debug exposing (log)

type alias Model =
  { drag : Drag.Model
  , startValue : Float
  , value : Float
  , step : Float
  , affix : String
  , min : Float
  , max : Float
  , round : Int
  , label : String
  , focusNext : Bool
  , focused : Bool
  , editing : Bool
  }

init : Float -> Model
init value =
  { drag = Drag.init
  , startValue = value
  , value = value
  , step = 1
  , affix = "px"
  , min = -(1/0)
  , max = (1/0)
  , round = 0
  , label = "width"
  , focusNext = False
  , focused = False
  , editing = False
  }

type Action
  = Lift (Html.Extra.DnD)
  | DoubleClick (Html.Extra.DnD)
  | Focus
  | Blur
  | Input String

update action model =
  case action of
    Input value ->
      { model | value = Result.withDefault 0 (String.toFloat value) }
    Focus ->
      { model | focusNext = False, focused = True }
    Blur ->
      { model | focused = False, editing = False }
    DoubleClick {dimensions, position} ->
      { model | editing = True}
        |> focus
    Lift {dimensions, position} ->
      { model | drag = Drag.lift dimensions position model.drag
              , startValue = model.value }

isInRegion dimensions position =
  abs (dimensions.left + (dimensions.width / 2) - position.pageX) <= dimensions.width / 10

focus model =
  if model.focused then
    model
  else
    { model | focusNext = True }

handleMove x y model =
  let
    diff = (Drag.diff x y model.drag).left
  in
    if model.drag.dragging then
      { model | value = model.startValue - (-diff * model.step) }
        |> clampValue
    else
      model

clampValue model =
  { model | value = clamp model.min model.max model.value }

handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag }



view address model =
  let
    asd =
      if model.editing then
        input [ onFocus address Focus
              , onBlur address Blur
              , value (toString model.value)
              , onInput address Input
              ] []
      else
        node "ui-number-range-input"
          [onWithDimensions "mousedown" True address Lift
          ,onWithDimensions "dblclick" True address DoubleClick]
          [text ((toString model.value) ++ model.affix)]

    input' =
      if model.focusNext then
        Native.Browser.focus asd
      else
        asd
  in
    node
      "ui-number-range"
      [ ]
      [ asd
      ]
