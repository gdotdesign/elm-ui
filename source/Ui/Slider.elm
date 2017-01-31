module Ui.Slider exposing
  (Model, Msg, init, onChange, subscriptions, update, view, render, setValue)

{-| Simple slider component.

# Model
@docs Model, Msg, init, subscriptions, update

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Attributes exposing (style, id)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import DOM exposing (Position)

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui

import Ui.Styles.Slider exposing (defaultStyle)
import Ui.Styles

{-| Representation of a slider:
  - **disabled** - Whether or not the slider is disabled
  - **readonly** - Whether or not the slider is readonly
  - **uid** - The unique identifier of the slider
  - **value** - The current value (0 - 100)
  - **drag** - The drag for the slider
-}
type alias Model =
  { drag : Drag.Drag
  , disabled : Bool
  , readonly : Bool
  , value : Float
  , uid : String
  }


{-| Messages that a slider can receive.
-}
type Msg
  = Lift Position
  | Move Position
  | Increment
  | Decrement
  | End


{-| Initializes a slider with the given value.

    slider =
      Ui.Slider.init
        |> Ui.Slider.setValue 0.5
-}
init : () -> Model
init _ =
  { uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , drag = Drag.init
  , value = 0
  }


{-| Subscribe to the changes of a slider.

    subscriptions = Ui.Slider.onChange SliderChanged slider
-}
onChange : (Float -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFloat model.uid msg


{-| Subscriptions for a slider.

    subscriptions = Sub.map Slider (Ui.Slider.subscriptions slider)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Drag.onMove Move model
    , Drag.onEnd End model
    ]


{-| Updates a slider.

    ( updatedSlider, cmd ) = Ui.Slider.update msg slider
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action ({ drag } as model) =
  case action of
    Move position ->
      updateValue position model

    End ->
      ( Drag.end model , Cmd.none )

    Decrement ->
      decrement model

    Increment ->
      increment model

    Lift position ->
      model
        |> Drag.lift position
        |> updateValue position


{-| Lazily renders a slider.

    Ui.Slider.view slider
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a slider.

    Ui.Slider.render slider
-}
render : Model -> Html.Html Msg
render model =
  let
    position =
      (toString model.value) ++ "%"

    actions =
      [ Drag.liftHandler Lift
      , onKeys True
          [ ( 40, Decrement )
          , ( 38, Increment )
          , ( 37, Decrement )
          , ( 39, Increment )
          ]
      ]
        |> Ui.enabledActions model

    attributes =
      [ Ui.attributeList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
      , Ui.Styles.apply defaultStyle
      , [ id model.uid ]
      , Ui.tabIndex model
      , actions
      ]
        |> List.concat

    bar =
      node "ui-slider-bar" []
        [ node "ui-slider-progress" [ style [ ( "width", position ) ] ] [] ]
  in
    node "ui-slider" attributes
      [ bar
      , node "ui-slider-handle" [ style [ ( "left", position ) ] ] []
      ]


{-| Sets the value of the slider.

    updatedSlider = Ui.Slider.setValue 10 slider
-}
setValue : Float -> Model -> Model
setValue value model =
  { model | value = clamp 0 100 value }


{-| Updates the value of the slider based on a position.
-}
updateValue : Position -> Model -> (Model, Cmd Msg)
updateValue position ({ drag } as model) =
  let
    value =
      Drag.relativePercentPosition position model
        |> .left
        |> (*) 100
        |> clamp 0 100
  in
    setValue value model
    |> sendValue


{-| Increments the slider by 1 percent.
-}
increment : Model -> ( Model, Cmd Msg )
increment model =
  setValue (model.value + 1) model
    |> sendValue


{-| Decrements the slider by 1 percent.
-}
decrement : Model -> ( Model, Cmd Msg )
decrement model =
  setValue (model.value - 1) model
    |> sendValue


{-| Sends the value to the app.
-}
sendValue : Model -> ( Model, Cmd Msg )
sendValue model =
  ( model, Emitter.sendFloat model.uid model.value )
