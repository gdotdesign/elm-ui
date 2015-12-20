module Ui.Slider
  (Model, Action, init, update, view, handleMove, handleClick) where

{-| Slider component. In order to use it property you need to
handle mouse events like so:

    model = { slider: Ui.Slider.init 0 }

    update act model =
      case act of
        MousePosition (x, y) ->
          { model | slider = Ui.Slider.handleMove x y model.slider }
        MouseIsDown value ->
          { model | slider = Ui.Slider.handleClick value model.slider }
        Slider act ->
          { model | slider = Ui.Slider.update act model.slider }

    StartApp.start { init = (model, Effects.none)
                   , view = view
                   , update = update
                   , inputs = [Signal.map MousePosition Mouse.position,
                               Signal.map MouseIsDown Mouse.isDown]
                   }

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs handleMove, handleClick
-}
import Html.Extra exposing (onWithDimensions, onKeys)
import Html.Attributes exposing (style, classList)
import Html exposing (node)
import Html.Lazy

import Native.Browser
import Dict

import Ui.Helpers.Drag as Drag
import Ui

{-| Representation of a slider:
  - **value** - The current value (0 - 100)
  - **startDistance** - The distance in pixels when the dragging can start
  - **disabled** - Whether or not the slide is disabled
  - **readonly** - Whether or not the slide is readonly
  - **dragging** (internal) - Wheter or not the slider is currently dragging
  - **top** (internal) - The top position of the handle
  - **left** (internal) - The left position of the handle
  - **dimensions** (internal) - The dimensions of the slider
  - **mouseStartPosition** (internal) - The start position of the mouse
-}
type alias Model =
  { drag : Drag.Model
  , left : Float
  , value : Float
  , startDistance : Float
  , disabled : Bool
  , readonly : Bool
  }

{-| Actions that a slider can make. -}
type Action
  = Lift (Html.Extra.DnD)
  | Nothing
  | Increment
  | Decrement

{-| Initializes a slider with the given value.

    Ui.Slider.init 0.5
-}
init : Float -> Model
init value =
  { drag = Drag.init
  , left = 0
  , value = value
  , startDistance = 0
  , disabled = False
  , readonly = False
  }

{-| Updates a slider. -}
update : Action -> Model -> Model
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

    _ ->
      model

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
      if model.disabled || model.readonly then []
      else [ onWithDimensions "mousedown" True address Lift
           , onKeys address Nothing (Dict.fromList [ (40, Increment)
                                                   , (38, Decrement)
                                                   , (37, Increment)
                                                   , (39, Decrement) ])
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
handleMove : Int -> Int -> Model -> Model
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
      model

{-| Updates a slider, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  { model | drag = Drag.handleClick value model.drag }

{-| Clamps left position of the handle to width of the slider. -}
clampLeft : Model -> Model
clampLeft model =
  { model | left = clamp 0 model.drag.dimensions.width model.left }
    |> updatePrecent

{-| Clamps the value of the model. -}
clampValue : Model -> Model
clampValue model =
  { model | value = clamp 0 100 model.value }

{-| Updates the value to match the current position. -}
updatePrecent : Model -> Model
updatePrecent model =
  { model | value = model.left / model.drag.dimensions.width * 100 }

{-| Returns the length of a point from 0,0. -}
distance : Drag.Point -> Float
distance diff =
  sqrt diff.top^2 + diff.left^2

{-| Increments the model by 1 percent. -}
increment : Model -> Model
increment model =
  { model | value = model.value + 1 }
    |> clampValue

{-| Decrements the model by 1 percent. -}
decrement : Model -> Model
decrement model =
  { model | value = model.value - 1 }
    |> clampValue
