module Ui.Slider
  ( Model, Action, init, initWithAddress, update, view, handleMove, handleClick
  , setValue) where

{-| Simple slider component.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs handleMove, handleClick, setValue
-}
import Html.Extra exposing (onWithDimensions, onKeys)
import Html.Attributes exposing (style, classList)
import Html exposing (node)
import Html.Lazy

import Native.Browser
import Ext.Signal
import Effects
import Signal
import Dict

import Ui.Helpers.Drag as Drag
import Ui

{-| Representation of a slider:
  - **startDistance** - The distance in pixels when the dragging can start
  - **valueAddress** - The address to send the changes in value
  - **disabled** - Whether or not the slider is disabled
  - **readonly** - Whether or not the slider is readonly
  - **value** - The current value (0 - 100)
  - **left** (internal) - The left position of the handle
  - **drag** (internal) - The drag for the slider
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Float)
  , startDistance : Float
  , drag : Drag.Model
  , disabled : Bool
  , readonly : Bool
  , value : Float
  , left : Float
  }

{-| Actions that a slider can make. -}
type Action
  = Lift (Html.Extra.PositionAndDimension)
  | Increment
  | Decrement
  | Tasks ()

{-| Initializes a slider with the given value.

    Slider.init 0.5
-}
init : Float -> Model
init value =
  { valueAddress = Nothing
  , startDistance = 0
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , value = value
  , left = 0
  }

{-| Initializes a slider with the given value.

    Slider.init (forwardTo address SliderChanged) 0.5
-}
initWithAddress : Signal.Address Float -> Float -> Model
initWithAddress valueAddress value =
  let
    model = init value
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a slider. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Decrement ->
      increment model

    Increment ->
      decrement model

    Lift {dimensions, position} ->
      { model | drag = Drag.lift dimensions position model.drag
              , left = position.pageX - dimensions.left }
        |> clampLeft

    Tasks _ ->
      (model, Effects.none)

{-| Renders a slider. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    position =
      (toString (clamp 0 100 model.value)) ++ "%"

    actions =
      Ui.enabledActions model
        [ onWithDimensions "mousedown" True address Lift
        , onKeys address [ (40, Increment)
                         , (38, Decrement)
                         , (37, Increment)
                         , (39, Decrement)
                         ]
        ]

    element =
      node "ui-slider"
        ([ classList [ ("disabled", model.disabled)
                     , ("readonly", model.readonly)
                     ]
         ] ++ (Ui.tabIndex model) ++ actions)
        [ node "ui-slider-bar" []
          [ node "ui-slider-progress" [style [("width", position)]] [] ]
        , node "ui-slider-handle" [style [("left", position)]] [] ]
  in
    if model.drag.dragging && not model.disabled && not model.readonly then
      Native.Browser.focus element
    else
      element

{-| Updates a sliders value by coordinates. -}
handleMove : Int -> Int -> Model -> (Model, Effects.Effects Action)
handleMove x y model =
  let
    dist = distance diff
    diff = Drag.diff x y model.drag

    left =
      if dist >= model.startDistance then
        model.drag.mouseStartPosition.pageX + diff.left - model.drag.dimensions.left
      else
        model.left

  in
    if model.drag.dragging then
      { model | left = left }
        |> clampLeft
    else
      (model, Effects.none)

{-| Updates a slider, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag }

{-| Clamps left position of the handle to width of the slider. -}
clampLeft : Model -> (Model, Effects.Effects Action)
clampLeft model =
  { model | left = clamp 0 model.drag.dimensions.width model.left }
    |> updatePrecent

{-| Updates the value to match the current position. -}
updatePrecent : Model -> (Model, Effects.Effects Action)
updatePrecent model =
  setValue (model.left / model.drag.dimensions.width * 100) model

{-| Returns the length of a point from 0,0. -}
distance : Drag.Point -> Float
distance diff =
  sqrt diff.top^2 + diff.left^2

{-| Increments the slider by 1 percent. -}
increment : Model -> (Model, Effects.Effects Action)
increment model =
  setValue (model.value + 1) model

{-| Decrements the slider by 1 percent. -}
decrement : Model -> (Model, Effects.Effects Action)
decrement model =
  setValue (model.value - 1) model

{-| Sets the value of the slider. -}
setValue : Float -> Model -> (Model, Effects.Effects Action)
setValue value model =
  let
    clampedValue = clamp 0 100 value
  in
    ( { model | value = clampedValue }
    , Ext.Signal.sendAsEffect model.valueAddress clampedValue Tasks)
