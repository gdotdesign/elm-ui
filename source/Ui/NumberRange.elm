module Ui.NumberRange
  ( Model, Action, init, update, view, focus, handleClick, handleMove, setValue
  , increment, decrement ) where

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs focus, handleClick, handleMove, setValue, increment, decrement
-}
import Html.Extra exposing (onWithDimensions, onKeys, onInput, onEnterStop)
import Html.Attributes exposing (value, readonly, disabled, classList)
import Html.Events exposing (onFocus, onBlur)
import Html exposing (node, input)
import Html.Lazy

import Ext.Number exposing (formatFloat)
import Json.Decode as Json
import Native.Browser
import Result
import String
import Dict

import Ui.Helpers.Drag as Drag
import Ui

{-| Representation of a number range:
  - **value** - The current value
  - **step** - The step to increment / decrement by (per pixel, or per keyboard action)
  - **affix** - The affix string to display (for example px, %, em, s)
  - **min** - The minimum allowed value
  - **max** - The maximum allowed value
  - **round** - The decimals to round the value
  - **disabled** - Whether or not the component is disabled
-}
type alias Model =
  { drag : Drag.Model
  , startValue : Float
  , inputValue : String
  , value : Float
  , step : Float
  , affix : String
  , min : Float
  , max : Float
  , round : Int
  , focusNext : Bool
  , focused : Bool
  , editing : Bool
  , disabled : Bool
  }

{-| Actions that a number range can make. -}
type Action
  = Lift (Html.Extra.DnD)
  | DoubleClick (Html.Extra.DnD)
  | Focus
  | Blur
  | Input String
  | Nothing
  | Increment
  | Decrement
  | Save

{-| Initializes a number range by the given value. -}
init : Float -> Model
init value =
  { drag = Drag.init
  , startValue = value
  , inputValue = ""
  , value = value
  , step = 1
  , affix = "px"
  , min = -(1/0)
  , max = (1/0)
  , round = 0
  , focusNext = False
  , focused = False
  , editing = False
  , disabled = False
  }

{-| Updates a number range. -}
update: Action -> Model -> Model
update action model =
  case action of
    Nothing ->
      model
    Increment ->
      increment model
    Decrement ->
      decrement model
    Save ->
      endEdit model
    Input value ->
      { model | inputValue = value }
    Focus ->
      { model | focusNext = False, focused = True }
    Blur ->
      { model | focused = False }
        |> endEdit
    DoubleClick {dimensions, position} ->
      { model | editing = True
              , inputValue = formatFloat model.round model.value }
        |> focus
    Lift {dimensions, position} ->
      { model | drag = Drag.lift dimensions position model.drag
              , startValue = model.value }
        |> focus

{-| Renders a number range. -}
view: Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render: Signal.Address Action -> Model -> Html.Html
render address model =
  let
    attributes =
      if model.editing then
        [ value model.inputValue
        , onInput address Input
        , onEnterStop address Save
        ]
      else
        [ onWithDimensions "mousedown" True address Lift
        , onWithDimensions "dblclick" True address DoubleClick
        , value ((formatFloat model.round model.value) ++ model.affix)
        , onKeys address Nothing (Dict.fromList [ (40, Decrement)
                                                , (38, Increment)
                                                , (37, Decrement)
                                                , (39, Increment) ])
        ]

    inputElement =
      input ([ onFocus address Focus
             , onBlur address Blur
             , readonly (not model.editing)
             , disabled model.disabled
             ] ++ attributes) []

    focusedInput =
      case model.focusNext of
        True -> Native.Browser.focus inputElement
        False -> inputElement
  in
    node "ui-number-range" [classList [("disabled", model.disabled)]] [ focusedInput ]

{-| Focused the component. -}
focus : Model -> Model
focus model =
  case model.focused of
    True -> model
    False -> { model | focusNext = True }

{-| Updates a number range value by coordinates. -}
handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  let
    diff = (Drag.diff x y model.drag).left
  in
    if model.drag.dragging then
      setValue (model.startValue - (-diff * model.step)) model
    else
      model

{-| Updates a number range, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag }

{-| Sets the value of a number range. -}
setValue : Float -> Model -> Model
setValue value model =
  { model | value = clamp model.min model.max value }

{-| Increments a number ranges value by it's defined step. -}
increment : Model -> Model
increment model =
  setValue (model.value + model.step) model

{-| Decrements a number ranges value by it's defined step. -}
decrement : Model -> Model
decrement model =
  setValue (model.value - model.step) model

-- Exits a number range from its editing mode.
endEdit : Model -> Model
endEdit model =
  case model.editing of
    False -> model
    True -> { model | value = Result.withDefault 0 (String.toFloat model.inputValue)
            , editing = False }
