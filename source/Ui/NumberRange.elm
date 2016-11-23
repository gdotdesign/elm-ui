module Ui.NumberRange exposing
  ( Model, Msg, init, subscribe, subscriptions, update, view, render
  , setValue, increment, decrement )

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view, render

# Functions
@docs setValue, increment, decrement
-}

import Html.Attributes exposing (value, readonly, disabled, classList, id)
import Html.Events.Extra exposing (onKeys, onEnterPreventDefault)
import Html.Events exposing (onInput, onBlur, on)
import Html exposing (node, input)
import Html.Lazy

import Ext.Number exposing (toFixed)
import Process
import Result
import String
import Task

import Json.Decode as Json

import DOM exposing (Position)

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui

{-| Representation of a number range:
  - **startValue** - The value when the dragging starts
  - **inputValue** - The value of the input element editing
  - **drag** - The drag model
  - **disabled** - Whether or not the number range is disabled
  - **readonly** - Whether or not the number range is readonly
  - **editing** - Whether or not the number range is in edit mode
  - **affix** - The affix string to display (for example px, %, em, s)
  - **value** - The current value
  - **step** - The step to increment / decrement by (per pixel, or per keyboard action)
  - **min** - The minimum allowed value
  - **max** - The maximum allowed value
  - **round** - The decimals to round the value
  - **uid** - The unique identifier of the number range
-}
type alias Model =
  { inputValue : String
  , startValue : Float
  , drag : Drag.Drag
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


{-| Messages that a number range can receive.
-}
type Msg
  = Move Position
  | Lift Position
  | Input String
  | Increment
  | Decrement
  | NoOpTask (Result DOM.Error ())
  | Edit
  | Blur
  | Save
  | End


{-| Initializes a number range by the given value.

    numberRange = Ui.NumberRange.init 0
-}
init : Float -> Model
init value =
  { uid = Uid.uid ()
  , startValue = value
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , editing = False
  , inputValue = ""
  , value = value
  , affix = ""
  , min =
      -(1 / 0)
      -- Minus Infinity
  , max =
      (1 / 0)
      -- Plus Infinity
  , round = 0
  , step = 1
  }


{-| Subscribe to the changes of a number range.

    ...
    subscriptions =
      \model -> Ui.NumberRange.subscribe NumberRangeChanged model.numberRange
    ...
-}
subscribe : (Float -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listenFloat model.uid msg


{-| Subscriptions for a number range.

    ...
    subscriptions =
      \model ->
        Sub.map
          NumberRange
          (Ui.NumberRange.subscriptions model.numberRange)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Drag.onMove Move model
    , Drag.onEnd End model
    ]


{-| Updates a number range.

    Ui.NumberRange.update msg numberRange
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Increment ->
      increment model

    Decrement ->
      decrement model

    Save ->
      endEdit model

    Move position ->
      handleMove position model

    End ->
      ( Drag.end model, Cmd.none )

    Input value ->
      ( { model | inputValue = value }, Cmd.none )

    Blur ->
      endEdit model

    Edit ->
      ( { model
          | editing = True
          , inputValue = toFixed model.round model.value
        }
      , Task.attempt NoOpTask (DOM.select (DOM.idSelector model.uid))
      )

    Lift position ->
      ( { model | startValue = model.value }
          |> Drag.lift position
      , Task.attempt NoOpTask (DOM.focus (DOM.idSelector model.uid))
      )

    _ ->
      ( model, Cmd.none )


{-| Lazily renders a number range.

    Ui.NumberRange.view numberRange
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a number range.

    Ui.NumberRange.render numberRange
-}
render : Model -> Html.Html Msg
render model =
  let
    actions =
      if model.readonly || model.disabled then
        []
      else if model.editing then
        [ onInput Input
        , onEnterPreventDefault Save
        ]
      else
        [ Drag.liftHandler Lift
        , on "dblclick" (Json.succeed Edit)
        , onKeys
            [ ( 40, Decrement )
            , ( 38, Increment )
            , ( 37, Decrement )
            , ( 39, Increment )
            , ( 13, Edit )
            ]
        ]

    attributes =
      if model.editing then
        [ value model.inputValue ]
      else
        [ value ((toFixed model.round model.value) ++ model.affix) ]

    inputElement =
      input
        ([ onBlur Blur
         , readonly (not model.editing)
         , disabled model.disabled
         , id model.uid
         ]
          ++ attributes
          ++ actions
        )
        []
  in
    node
      "ui-number-range"
      [ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      ]
      [ inputElement ]


{-| Sets the value of a number range.

    Ui.NumberRange.setValue 1 numberRange
-}
setValue : Float -> Model -> Model
setValue value model =
  if model.value == value then
    model
  else
    { model | value = clamp model.min model.max value }


{-| Increments a number ranges value by it's defined step.

    Ui.NumberRange.increment numberRange
-}
increment : Model -> ( Model, Cmd Msg )
increment model =
  setValue (model.value + model.step) model
    |> sendValue


{-| Decrements a number ranges value by it's defined step.

    Ui.NumberRange.decrement numberRange
-}
decrement : Model -> ( Model, Cmd Msg )
decrement model =
  setValue (model.value - model.step) model
    |> sendValue



----------------------------------- PRIVATE ------------------------------------


{-| Sends the value to the signal
-}
sendValue : Model -> ( Model, Cmd Msg )
sendValue model =
  ( model, Emitter.sendFloat model.uid model.value )


{-| Updates a number range value by coordinates.
-}
handleMove : Position -> Model -> ( Model, Cmd Msg )
handleMove position model =
  let
    left =
      Drag.diff position model
        |> .left
  in
    if model.drag.dragging then
      setValue (model.startValue - (-left * model.step)) model
        |> sendValue
    else
      ( model, Cmd.none )


{-| Exits a number range from its editing mode.
-}
endEdit : Model -> ( Model, Cmd Msg )
endEdit model =
  case model.editing of
    False ->
      ( model, Cmd.none )

    True ->
      { model | editing = False }
        |> setValue (Result.withDefault 0 (String.toFloat model.inputValue))
        |> sendValue
