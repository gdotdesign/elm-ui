module Ui.NumberRange exposing
  ( Model, Msg, init, onChange, subscriptions, update, view, render, min, max
  , setValue, increment, decrement, affix, keyboardStep, dragStep, round )

{-| This is a component allows the user to change a number value by
dragging or by using the keyboard, also traditional editing is enabled by
double clicking on the component.

# Model
@docs Model, Msg, init, subscriptions, update

# Events
@docs onChange

# DSL
@docs affix, keyboardStep, dragStep, min, max, round

# View
@docs view, render

# Functions
@docs setValue, increment, decrement
-}

import Html.Events.Extra exposing (onKeys, onEnterPreventDefault)
import Html.Attributes exposing (readonly, disabled, id)
import Html.Events exposing (onInput, onBlur, on)
import Html exposing (node, input)
import Html.Lazy

import Ext.Number exposing (toFixed)
import Json.Decode as Json
import Result
import String
import Task

import DOM exposing (Position)

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui

import Ui.Styles.NumberRange exposing (defaultStyle)
import Ui.Styles

{-| Representation of a number range:
  - **keyboardStep** - The interval to increment / decrement by (per keyboard action)
  - **affix** - The affix string to display (for example px, %, em, s)
  - **dragStep** - The interval to increment / decrement by (per pixel)
  - **editing** - Whether or not the number range is in edit mode
  - **disabled** - Whether or not the number range is disabled
  - **readonly** - Whether or not the number range is readonly
  - **inputValue** - The value of the input element editing
  - **startValue** - The value when the dragging starts
  - **uid** - The unique identifier of the number range
  - **round** - The decimals to round the value
  - **min** - The minimum allowed value
  - **max** - The maximum allowed value
  - **value** - The current value
  - **drag** - The drag model
-}
type alias Model =
  { inputValue : Maybe String
  , keyboardStep : Float
  , startValue : Float
  , dragStep : Float
  , drag : Drag.Drag
  , disabled : Bool
  , readonly : Bool
  , editing : Bool
  , affix : String
  , value : Float
  , uid : String
  , min : Float
  , max : Float
  , round : Int
  }


{-| Messages that a number range can receive.
-}
type Msg
  = NoOpTask (Result DOM.Error ())
  | StartEdit Float
  | Move Position
  | Lift Position
  | Input String
  | Increment
  | Decrement
  | Edit
  | Blur
  | Save
  | End


{-| Initializes a number range by the given value.

    numberRange =
      Ui.NumberRange.init ()
        |> Ui.NumberRange.affix "px"
        |> Ui.NumberRange.round 1
        |> Ui.NubmerRange.min 0
-}
init : () -> Model
init _ =
  { inputValue = Nothing
  , uid = Uid.uid ()
  , keyboardStep = 1
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , editing = False
  , startValue = 0
  , min = -(1 / 0)
  , max = (1 / 0)
  , dragStep = 1
  , affix = ""
  , value = 0
  , round = 0
  }


{-| Sets the affix of a number range.
-}
affix : String -> Model -> Model
affix value model =
  { model | affix = value }


{-| Sets the interval of a number range when dragging .
-}
dragStep : Float -> Model -> Model
dragStep value model =
  { model | dragStep = value }


{-| Sets the interval of a number range when using the keyboard.
-}
keyboardStep : Float -> Model -> Model
keyboardStep value model =
  { model | keyboardStep = value }


{-| Sets the minimum value of a number range.
-}
min : Float -> Model -> Model
min value model =
  { model | min = value }


{-| Sets the maximum value of a number range.
-}
max : Float -> Model -> Model
max value model =
  { model | max = value }


{-| Sets the how many digits to round the value of a number range.
-}
round : Int -> Model -> Model
round value model =
  { model | round = value }


{-| Subscribe to the changes of a number range.

    subscriptions = Ui.NumberRange.onChange NumberRangeChanged numberRange
-}
onChange : (Float -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFloat model.uid msg


{-| Subscriptions for a number range.

    subscriptions =
      Sub.map NumberRange (Ui.NumberRange.subscriptions numberRange)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Drag.onMove Move model
    , Drag.onEnd End model
    ]


{-| Updates a number range.

    ( updatedNumberRange, cmd ) = Ui.NumberRange.update msg numberRange
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
      ( { model | inputValue = Just value }, Cmd.none )

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


{-| Starts editing.
-}
edit : Float -> Bool -> Model -> (Model, Cmd Msg)
edit value select model =
  let
    val =
      toFixed model.round value

    selector =
      DOM.idSelector model.uid

    selectOrFocus =
      if select then
        DOM.focus selector
        |> Task.andThen (\_ -> DOM.select selector)
      else
        DOM.focus selector

    cmd =
      DOM.setValue val selector
        |> Task.andThen (\_ -> selectOrFocus)
        |> Task.attempt NoOpTask
  in
    ( { model | editing = True, inputValue = Just val }, cmd )


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
    (_, val) =
      formatValue model.value model

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
        , onKeys True
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
        ([ Html.Attributes.defaultValue val
         , readonly (not model.editing)
         , disabled model.disabled
         , id model.uid
         , onBlur Blur
         ]
          ++ actions
        )
        []
  in
    node
      "ui-number-range"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ inputElement ]


{-| Sets the value of a number range.

    ( updatedNumberRange, cmd ) =
      Ui.NumberRange.setValue 1 numberRange
-}
setValue : Float -> Model -> ( Model, Cmd Msg )
setValue value model =
  let
    (clamped, val) =
      formatValue value model

    task =
      DOM.setValue val (DOM.idSelector model.uid)
  in
    if model.value == value
    && model.inputValue == Nothing
    then
      ( model, Cmd.none)
    else
      ( { model | value = clamped, inputValue = Nothing }
      , Task.attempt NoOpTask task )


{-| Formats the given value.
-}
formatValue : Float -> Model -> (Float, String)
formatValue value model =
  let
    clamped =
      clamp model.min model.max value
  in
    (clamped, (toFixed model.round clamped) ++ model.affix)


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


{-| Sends the value to the app.
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
  let
    value =
      if model.editing then
        model.inputValue
          |> Maybe.withDefault "0"
          |> String.toFloat
          |> Result.withDefault 0
      else
        model.value
  in
    { model | editing = False }
      |> setValue value
      |> sendValue
