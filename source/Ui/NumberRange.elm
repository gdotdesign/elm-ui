module Ui.NumberRange exposing
  ( Model, Msg, init, subscriptions, update, view, focus, setValue, increment, decrement )

-- where

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view

# Functions
@docs focus, setValue, increment, decrement
-}
import Html.Events.Geometry as Geometry exposing (Dimensions, onWithDimensions)
import Html.Events.Extra exposing (onKeys, onEnterPreventDefault, onStop)
import Html.Attributes exposing (value, readonly, disabled, classList)
import Html.Events exposing (onInput, onBlur)
import Html exposing (node, input)

import Ext.Number exposing (toFixed)
import Json.Decode as Json
import Native.Browser
import Result
import String
import Dict

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui

{-| Representation of a number range:
  - **step** - The step to increment / decrement by (per pixel, or per keyboard action)
  - **affix** - The affix string to display (for example px, %, em, s)
  - **valueAddress** - The address to send the changes in value
  - **disabled** - Whether or not the number range is disabled
  - **readonly** - Whether or not the number range is readonly
  - **round** - The decimals to round the value
  - **min** - The minimum allowed value
  - **max** - The maximum allowed value
  - **value** - The current value
  - **editing** (internal) - Whether or not the number range is in edit mode
  - **startValue** (internal) - The value when the dragging starts
  - **inputValue** (internal) - The inputs value when editing
  - **drag** (internal) - The drag model
-}
type alias Model =
  { inputValue : String
  , startValue : Float
  , drag : Drag.Model
  , disabled : Bool
  , readonly : Bool
  , editing : Bool
  , affix : String
  , value : Float
  , step : Float
  , min : Float
  , max : Float
  , round : Int
  , uid : String
  }

{-| Actions that a number range can make. -}
type Msg
  = Lift Dimensions
  | Input String
  | Increment
  | Decrement
  | Tasks ()
  | Move (Float, Float)
  | Click Bool
  | Edit
  | Blur
  | Save

{-| Initializes a number range by the given value.

    NumberRange.init 0
-}
init : Float -> Model
init value =
  { startValue = value
  , drag = Drag.init
  , uid = Native.Uid.uid ()
  , disabled = False
  , readonly = False
  , editing = False
  , inputValue = ""
  , value = value
  , affix = "px"
  , min = -(1/0) -- Minus Infinity
  , max = (1/0) -- Plus Infinity
  , round = 0
  , step = 1
  }

subscribe : (Float -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listenFloat model.uid msg

subscriptions : Sub Msg
subscriptions =
  Drag.subscriptions Move Click

{-| Updates a number range. -}
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Increment ->
      increment model

    Decrement ->
      decrement model

    Save ->
      endEdit model

    Move (x, y) ->
      handleMove x y model

    Click pressed ->
      (handleClick pressed model, Cmd.none)

    Input value ->
      ({ model | inputValue = value }, Cmd.none)

    Blur ->
      endEdit model

    Edit ->
      ({ model | editing = True
               , inputValue = toFixed model.round model.value }, Cmd.none)

    Lift (position, dimensions, size) ->
      ({ model | drag = Drag.lift dimensions position model.drag
               , startValue = model.value }, Cmd.none)

    Tasks _ ->
      (model, Cmd.none)

-- Sends the value to the signal
sendValue : Model -> (Model, Cmd Msg)
sendValue model =
  (model, Emitter.sendFloat model.uid model.value)

{-| Renders a number range. -}
view: Model -> Html.Html Msg
view model =
  render model

-- Render internal
render: Model -> Html.Html Msg
render model =
  let
    actions =
      if model.readonly || model.disabled then []
      else if model.editing then
        [ onInput Input
        , onEnterPreventDefault Save
        ]
      else
        [ onWithDimensions "mousedown" False Lift
        , onStop "dblclick" Edit
        , onKeys [ (40, Decrement)
                 , (38, Increment)
                 , (37, Decrement)
                 , (39, Increment)
                 , (13, Edit)
                 ]
        ]
    attributes =
      if model.editing then
        [ value model.inputValue ]
      else
        [ value ((toFixed model.round model.value) ++ model.affix) ]

    inputElement =
      input ([ onBlur Blur
             , readonly (not model.editing)
             , disabled model.disabled
             ] ++ attributes ++ actions) []
  in
    node "ui-number-range"
      [ classList [ ("disabled", model.disabled)
                  , ("readonly", model.readonly)
                  ]
      ]
      [ inputElement ]

{-| Focuses the component. -}
focus : Model -> Model
focus model =
  model
  -- TODO: Use task here

{-| Updates a number range value by coordinates. -}
handleMove : Float -> Float -> Model -> (Model, Cmd Msg)
handleMove x y model =
  let
    diff = (Drag.diff x y model.drag).left
  in
    if model.drag.dragging then
      setValue (model.startValue - (-diff * model.step)) model
      |> sendValue
    else
      (model, Cmd.none)

{-| Updates a number range, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  let
    drag = Drag.handleClick value model.drag
  in
    if model.drag == drag then
      model
    else
      { model | drag = drag }

{-| Sets the value of a number range. -}
setValue : Float -> Model -> Model
setValue value model =
  if model.value == value then
    model
  else
    { model | value = clamp model.min model.max value }

{-| Increments a number ranges value by it's defined step. -}
increment : Model -> (Model, Cmd Msg)
increment model =
  setValue (model.value + model.step) model
  |> sendValue

{-| Decrements a number ranges value by it's defined step. -}
decrement : Model -> (Model, Cmd Msg)
decrement model =
  setValue (model.value - model.step) model
  |> sendValue

-- Exits a number range from its editing mode.
endEdit : Model -> (Model, Cmd Msg)
endEdit model =
  case model.editing of
    False ->
      (model, Cmd.none)
    True ->
      { model | editing = False }
      |> setValue (Result.withDefault 0 (String.toFloat model.inputValue))
      |> sendValue
