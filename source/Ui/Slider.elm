module Ui.Slider exposing
  (Model, Msg, init, subscribe, subscriptions, update, view, render, setValue)

{-| Simple slider component.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Events.Geometry exposing (onWithDimensions, Dimensions)
import Html.Attributes exposing (style, classList)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Dict

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Browser as Browser
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui


{-| Representation of a slider:
  - **startDistance** - The distance in pixels when the dragging can start
  - **drag** - The drag for the slider
  - **disabled** - Whether or not the slider is disabled
  - **readonly** - Whether or not the slider is readonly
  - **value** - The current value (0 - 100)
  - **left** - The left position of the handle
  - **uid** - The unique identifier of the slider
-}
type alias Model =
  { startDistance : Float
  , drag : Drag.Model
  , disabled : Bool
  , readonly : Bool
  , value : Float
  , left : Float
  , uid : String
  }


{-| Messages that a slider can receive.
-}
type Msg
  = Move ( Float, Float )
  | Lift Dimensions
  | Click Bool
  | Increment
  | Decrement


{-| Initializes a slider with the given value.

    slider = Ui.Slider.init 0.5
-}
init : Float -> Model
init value =
  { uid = Uid.uid ()
  , startDistance = 0
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , value = value
  , left = 0
  }


{-| Subscribe to the changes of a slider.

    ...
    subscriptions =
      \model -> Ui.Slider.subscribe SliderChanged model.slider
    ...
-}
subscribe : (Float -> msg) -> Model -> Sub msg
subscribe msg model =
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
  Drag.subscriptions Move Click model.drag.dragging


{-| Updates a slider.

    Ui.Slider.update msg slider
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Decrement ->
      increment model

    Increment ->
      decrement model

    Move ( x, y ) ->
      handleMove x y model

    Click pressed ->
      handleClick pressed model

    Lift ( position, dimensions, size ) ->
      { model
        | drag = Drag.lift dimensions position model.drag
        , left = position.left - dimensions.left
      }
        |> clampLeft


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
      (toString (clamp 0 100 model.value)) ++ "%"

    actions =
      Ui.enabledActions
        model
        [ onWithDimensions "mousedown" False Lift
        , onKeys
            [ ( 40, Increment )
            , ( 38, Decrement )
            , ( 37, Increment )
            , ( 39, Decrement )
            ]
        ]

    element =
      node
        "ui-slider"
        ([ classList
            [ ( "disabled", model.disabled )
            , ( "readonly", model.readonly )
            ]
         ]
          ++ (Ui.tabIndex model)
          ++ actions
        )
        [ node
            "ui-slider-bar"
            []
            [ node "ui-slider-progress" [ style [ ( "width", position ) ] ] [] ]
        , node "ui-slider-handle" [ style [ ( "left", position ) ] ] []
        ]
  in
    element


{-| Sets the value of the slider.
-}
setValue : Float -> Model -> Model
setValue value model =
  { model | value = clamp 0 100 value }



----------------------------------- PRIVATE ------------------------------------


{-| Updates a sliders value by coordinates.
-}
handleMove : Float -> Float -> Model -> ( Model, Cmd Msg )
handleMove x y model =
  let
    dist =
      distance diff

    diff =
      Drag.diff x y model.drag

    left =
      if dist >= model.startDistance then
        model.drag.mouseStartPosition.left + diff.left - model.drag.dimensions.left
      else
        model.left
  in
    if model.drag.dragging then
      { model | left = left }
        |> clampLeft
    else
      ( model, Cmd.none )


{-| Updates a slider, stopping the drag if the mouse isnt pressed.
-}
handleClick : Bool -> Model -> ( Model, Cmd Msg )
handleClick value model =
  ( { model | drag = Drag.handleClick value model.drag }, Cmd.none )


{-| Clamps left position of the handle to width of the slider.
-}
clampLeft : Model -> ( Model, Cmd Msg )
clampLeft model =
  { model | left = clamp 0 model.drag.dimensions.width model.left }
    |> updatePrecent
    |> sendValue


{-| Updates the value to match the current position.
-}
updatePrecent : Model -> Model
updatePrecent model =
  setValue (model.left / model.drag.dimensions.width * 100) model


{-| Returns the length of a point from 0,0.
-}
distance : Drag.Point -> Float
distance diff =
  sqrt diff.top ^ 2 + diff.left ^ 2


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
