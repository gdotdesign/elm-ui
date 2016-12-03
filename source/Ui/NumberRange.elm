module Ui.NumberRange exposing
  ( Model, Msg, init, onChange, subscriptions, update, view, render
  , setValue, increment, decrement, affix, keyboardStep, dragStep )

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Msg, init, subscriptions, update

# Events
@docs onChange

# DSL
@docs affix, keyboardStep, dragStep

# View
@docs view, render

# Functions
@docs setValue, increment, decrement
-}

import Html.Attributes exposing (readonly, disabled, classList, id)
import Html.Events.Extra exposing (onKeys, onEnterPreventDefault)
import Html.Events exposing (onInput, onBlur, on)
import Html exposing (node, input)
import Html.Lazy

import Ext.Number exposing (toFixed)
import Result
import String
import Task

import Json.Decode as Json

import DOM exposing (Position)

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid

{-| Representation of a number range:
  - **step** - The step to increment / decrement by (per pixel, or per keyboard action)
  - **affix** - The affix string to display (for example px, %, em, s)
  - **inputValue** - The value of the input element editing
  - **startValue** - The value when the dragging starts
  - **drag** - The drag model
  - **editing** - Whether or not the number range is in edit mode
  - **disabled** - Whether or not the number range is disabled
  - **readonly** - Whether or not the number range is readonly
  - **value** - The current value
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
  , dragStep : Float
  , keyboardStep : Float
  , min : Float
  , max : Float
  , round : Int
  , uid : String
  }


{-| Messages that a number range can receive.
-}
type Msg
  = Move Position
  | NoOpTask (Result DOM.Error ())
  | StartEdit Float
  | Lift Position
  | Input String
  | Increment
  | Decrement
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
  , dragStep = 1
  , keyboardStep = 1
  }


{-|-}
affix : String -> Model -> Model
affix value model =
  { model | affix = value }


{-|-}
dragStep : Float -> Model -> Model
dragStep value model =
  { model | dragStep = value }

{-|-}
keyboardStep : Float -> Model -> Model
keyboardStep value model =
  { model | keyboardStep = value }

{-| Subscribe to the changes of a number range.

    ...
    subscriptions =
      \model -> Ui.NumberRange.onChange NumberRangeChanged model.numberRange
    ...
-}
onChange : (Float -> msg) -> Model -> Sub msg
onChange msg model =
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

    StartEdit value ->
      edit value False model

    Edit ->
      edit model.value True model

    Lift position ->
      ( { model | startValue = model.value }
          |> Drag.lift position
      , Task.attempt NoOpTask (DOM.focus (DOM.idSelector model.uid))
      )

    _ ->
      ( model, Cmd.none )


edit value select model =
  let
    val =
      toFixed model.round value

    cmd =
      DOM.setValue val (DOM.idSelector model.uid)
      |> Task.andThen (\_ ->
        if select then
          DOM.select (DOM.idSelector model.uid)
        else
          DOM.focus (DOM.idSelector model.uid)
        )
      |> Task.attempt NoOpTask
  in
    ( { model
        | editing = True
        , inputValue = val
      }
    , cmd
    )


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
            , ( 48, (StartEdit 0) )
            , ( 49, (StartEdit 1) )
            , ( 50, (StartEdit 2) )
            , ( 51, (StartEdit 3) )
            , ( 52, (StartEdit 4) )
            , ( 53, (StartEdit 5) )
            , ( 54, (StartEdit 6) )
            , ( 55, (StartEdit 7) )
            , ( 56, (StartEdit 8) )
            , ( 57, (StartEdit 9) )
            , ( 96, (StartEdit 0) )
            , ( 97, (StartEdit 1) )
            , ( 98, (StartEdit 2) )
            , ( 99, (StartEdit 3) )
            , ( 100, (StartEdit 4) )
            , ( 101, (StartEdit 5) )
            , ( 102, (StartEdit 6) )
            , ( 103, (StartEdit 7) )
            , ( 104, (StartEdit 8) )
            , ( 105, (StartEdit 9) )
            ]
        ]

    inputElement =
      input
        ([ onBlur Blur
         , Html.Attributes.defaultValue "0"
         , readonly (not model.editing)
         , disabled model.disabled
         , id model.uid
         ]
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
setValue : Float -> Model -> ( Model, Cmd Msg )
setValue value model =
  let
    clamped =
      clamp model.min model.max value

    val =
      ((toFixed model.round clamped) ++ model.affix)

    task =
      DOM.setValue val (DOM.idSelector model.uid)
  in
    if model.value == value then
      ( model, Cmd.none)
    else
      ( { model | value = clamped }
      , Task.attempt NoOpTask task )


{-| Increments a number ranges value by it's defined step.

    Ui.NumberRange.increment numberRange
-}
increment : Model -> ( Model, Cmd Msg )
increment model =
  setValue (model.value + model.keyboardStep) model
    |> sendValue


{-| Decrements a number ranges value by it's defined step.

    Ui.NumberRange.decrement numberRange
-}
decrement : Model -> ( Model, Cmd Msg )
decrement model =
  setValue (model.value - model.keyboardStep) model
    |> sendValue



----------------------------------- PRIVATE ------------------------------------


{-| Sends the value to the signal
-}
sendValue : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
sendValue (model, cmd) =
  ( model, Cmd.batch [ Emitter.sendFloat model.uid model.value, cmd ] )


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
      setValue (model.startValue - (-left * model.dragStep)) model
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
