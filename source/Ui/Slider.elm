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

import Html.Attributes exposing (style, classList, id)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import DOM exposing (Position)

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui


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

    ...
    subscriptions =
      \model -> Ui.Slider.onChange SliderChanged model.slider
    ...
-}
onChange : (Float -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFloat model.uid msg


{-| Subscriptions for a slider.

    ...
    subscriptions =
      \model ->
        Sub.map
          Slider
          (Ui.Slider.subscriptions model.slider)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Drag.onMove Move model
    , Drag.onEnd End model
    ]


{-| Updates a slider.

    Ui.Slider.update msg slider
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action ({ drag } as model) =
  case action of
    Move position ->
      updateValue position model

    End ->
      ( Drag.end model , Cmd.none )

    Decrement ->
      increment model

    Increment ->
      decrement model

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
          [ ( 40, Increment )
          , ( 38, Decrement )
          , ( 37, Increment )
          , ( 39, Decrement )
          ]
      ]
        |> Ui.enabledActions model

    attributes =
      [ classList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
      , id model.uid
      ]
        |> (++) (Ui.tabIndex model)
        |> (++) actions

    bar =
      node "ui-slider-bar" []
        [ node "ui-slider-progress" [ style [ ( "width", position ) ] ] [] ]
  in
    node "ui-slider" attributes
      [ bar
      , node "ui-slider-handle" [ style [ ( "left", position ) ] ] []
      ]


{-| Sets the value of the slider.
-}
setValue : Float -> Model -> Model
setValue value model =
  { model | value = clamp 0 100 value }



----------------------------------- PRIVATE ------------------------------------

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


{-| Sends the value to the valueAddress.
-}
sendValue : Model -> ( Model, Cmd Msg )
sendValue model =
  ( model, Emitter.sendFloat model.uid model.value )
