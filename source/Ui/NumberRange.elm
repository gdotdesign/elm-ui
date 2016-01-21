module Ui.NumberRange
  ( Model, Action, init, initWithAddress, update, view, focus, handleClick
  , handleMove, setValue, increment, decrement ) where

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs focus, handleClick, handleMove, setValue, increment, decrement
-}
import Html.Extra exposing (onWithDimensions, onKeys, onInput,
                            onEnterPreventDefault, onStop)
import Html.Attributes exposing (value, readonly, disabled, classList)
import Html.Events exposing (onFocus, onBlur)
import Html exposing (node, input)
import Html.Lazy

import Ext.Number exposing (toFixed)
import Json.Decode as Json
import Native.Browser
import Ext.Signal
import Effects
import Result
import String
import Dict

import Ui.Helpers.Drag as Drag
import Ui.Utils.Env as Env
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
  - **focusNext** (internal) - Whether or not to focus the input
  - **focus** (internal) - Whether or not the input is focused
  - **inputValue** (internal) - The inputs value when editing
  - **drag** (internal) - The drag model
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Float)
  , inputValue : String
  , startValue : Float
  , drag : Drag.Model
  , focusNext : Bool
  , disabled : Bool
  , readonly : Bool
  , editing : Bool
  , focused : Bool
  , affix : String
  , value : Float
  , step : Float
  , min : Float
  , max : Float
  , round : Int
  }

{-| Actions that a number range can make. -}
type Action
  = Lift (Html.Extra.PositionAndDimension)
  | Input String
  | Increment
  | Decrement
  | Tasks ()
  | Focus
  | Edit
  | Blur
  | Save

{-| Initializes a number range by the given value.

    NumberRange.init 0
-}
init : Float -> Model
init value =
  { valueAddress = Nothing
  , startValue = value
  , focusNext = False
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , focused = False
  , editing = False
  , inputValue = ""
  , value = value
  , affix = "px"
  , min = -(1/0) -- Minus Infinity
  , max = (1/0) -- Plus Infinity
  , round = 0
  , step = 1
  }

{-| Initializes a slider with the given value and value address.

    NumberRange.init (forwardTo address SliderChanged) 0.5
-}
initWithAddress : Signal.Address Float -> Float -> Model
initWithAddress valueAddress value =
  let
    model = init value
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a number range. -}
update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Increment ->
      increment model

    Decrement ->
      decrement model

    Save ->
      endEdit model

    Input value ->
      ({ model | inputValue = value }, Effects.none)

    Focus ->
      ({ model | focusNext = False, focused = True }, Effects.none)

    Blur ->
      { model | focused = False }
        |> endEdit

    Edit ->
      ({ model | editing = True
               , inputValue = toFixed model.round model.value }
        |> focus, Effects.none)

    Lift {dimensions, position} ->
      ({ model | drag = Drag.lift dimensions position model.drag
               , startValue = model.value }
        |> focus, Effects.none)

    Tasks _ ->
      (model, Effects.none)

-- Sends the value to the signal
sendValue : Model -> (Model, Effects.Effects Action)
sendValue model =
  (model, Ext.Signal.sendAsEffect model.valueAddress model.value Tasks)

{-| Renders a number range. -}
view: Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render: Signal.Address Action -> Model -> Html.Html
render address model =
  let
    debug = Env.log "Rendered Ui.NumberRange..."

    actions =
      if model.readonly || model.disabled then []
      else if model.editing then
        [ onInput address Input
        , onEnterPreventDefault address Save
        ]
      else
        [ onWithDimensions "mousedown" False address Lift
        , onStop "dblclick" address Edit
        , onKeys address [ (40, Decrement)
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
      input ([ onFocus address Focus
             , onBlur address Blur
             , readonly (not model.editing)
             , disabled model.disabled
             ] ++ attributes ++ actions) []

    focusedInput =
      case model.focusNext && not model.disabled && not model.readonly of
        True -> Native.Browser.focus inputElement
        False -> inputElement
  in
    node "ui-number-range"
      [ classList [ ("disabled", model.disabled)
                  , ("readonly", model.readonly)
                  ]
      ]
      [ focusedInput ]

{-| Focused the component. -}
focus : Model -> Model
focus model =
  case model.focused of
    True -> model
    False -> { model | focusNext = True }

{-| Updates a number range value by coordinates. -}
handleMove : Int -> Int -> Model -> (Model, Effects.Effects Action)
handleMove x y model =
  let
    diff = (Drag.diff x y model.drag).left
  in
    if model.drag.dragging then
      setValue (model.startValue - (-diff * model.step)) model
    else
      (model, Effects.none)

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
setValue : Float -> Model -> (Model, Effects.Effects Action)
setValue value model =
  { model | value = clamp model.min model.max value }
  |> sendValue

{-| Increments a number ranges value by it's defined step. -}
increment : Model -> (Model, Effects.Effects Action)
increment model =
  setValue (model.value + model.step) model

{-| Decrements a number ranges value by it's defined step. -}
decrement : Model -> (Model, Effects.Effects Action)
decrement model =
  setValue (model.value - model.step) model

-- Exits a number range from its editing mode.
endEdit : Model -> (Model, Effects.Effects Action)
endEdit model =
  case model.editing of
    False ->
      (model, Effects.none)
    True ->
      { model | editing = False }
      |> setValue (Result.withDefault 0 (String.toFloat model.inputValue))
