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
import Html.Extra exposing (onWithDimensions, onKeysWithDimension)
import Html.Attributes exposing (style, classList)
import Html exposing (node)

import Native.Browser
import Dict

import Ui

{-| Representation of a slider:
  - **value** - The current value (0 - 100)
  - **startDistance** - The distance in pixels when the dragging can start
  - **disabled** - Whether or not the slide is disabled
  - **dragging** (internal) - Wheter or not the slider is currently dragging
  - **top** (internal) - The top position of the handle
  - **left** (internal) - The left position of the handle
  - **dimensions** (internal) - The dimensions of the slider
  - **mouseStartPosition** (internal) - The start position of the mouse
-}
type alias Model =
  { dragging : Bool
  , left : Float
  , top : Float
  , value : Float
  , startDistance : Float
  , dimensions : Html.Extra.Dimensions
  , mouseStartPosition : Html.Extra.Position
  , disabled : Bool
  }

{-| Actions that a slider can make. -}
type Action
  = Lift (Html.Extra.DnD)
  | Nothing
  | Increment (Html.Extra.Dimensions)
  | Decrement (Html.Extra.Dimensions)

{-| Initializes a slider with the given value.

    Ui.Slider.init 0.5
-}
init : Float -> Model
init value =
  { dragging = False
  , dimensions = { top = 0, left = 0, width = 0, height = 0 }
  , left = 0
  , value = value
  , startDistance = 0
  , mouseStartPosition = { pageX = 0, pageY = 0 }
  , top = 100
  , disabled = True
  }

{-| Updates a slider. -}
update : Action -> Model -> Model
update action model =
  case action of
    Decrement data ->
      updateDimensions data model
        |> increment

    Increment data ->
      updateDimensions data model
        |> decrement

    Lift {dimensions, position} ->
      { model | dragging = True
              , dimensions = dimensions
              , left = position.pageX - dimensions.left
              , mouseStartPosition = position }
        |> clampLeft

    _ ->
      model

{-| Renders a slider. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    position =
      (toString (clamp 0 100 model.value)) ++ "%"
    element =
      node "ui-slider" ((Ui.tabIndex model) ++
                       [ onWithDimensions "mousedown" address Lift
                       , classList [("disabled", model.disabled)]
                       , onKeysWithDimension address Nothing (Dict.fromList [ (40, Increment)
                                                                            , (38, Decrement)
                                                                            , (37, Increment)
                                                                            , (39, Decrement) ])
                       ])
                       [ node "ui-slider-bar" []
                         [ node "ui-slider-progress" [style [("width", position)]] [] ]
                       , node "ui-slider-handle" [style [("left", position)]] [] ]
  in
    if model.dragging then
      Native.Browser.focus element
    else
      element

{-| Updates a sliders value by coordinates. -}
handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  let
    dist =
      distance diff

    diff =
      { top = (toFloat y) - model.mouseStartPosition.pageY
      , left = (toFloat x) - model.mouseStartPosition.pageX
      }

    left =
      if dist >= model.startDistance then
        model.mouseStartPosition.pageX + diff.left - model.dimensions.left
      else
        model.left

    top =
      if dist >= model.startDistance then
        model.mouseStartPosition.pageY + diff.top - model.dimensions.top
      else
        model.top
  in
    if model.dragging then
      { model | left = left
               , top = top }
        |> clampLeft
    else
      model

{-| Updates a slider, stopping the drag if the mouse isnt pressed. -}
handleClick : Bool -> Model -> Model
handleClick value model =
  if not value && model.dragging then
    { model | dragging = False }
  else
    model

{-| Clamps left position of the handle to width of the slider. -}
clampLeft : Model -> Model
clampLeft model =
  { model | left = clamp 0 model.dimensions.width model.left }
    |> updatePrecent

{-| Clamps the value of the model. -}
clampValue : Model -> Model
clampValue model =
  { model | value = clamp 0 100 model.value }

{-| Updates the value to match the current position. -}
updatePrecent : Model -> Model
updatePrecent model =
  { model | value = model.left / model.dimensions.width * 100 }

{-| Returns the length of a point from 0,0. -}
distance : { a | top : Float, left : Float } -> Float
distance diff =
  sqrt diff.top^2 + diff.left^2

{-| Updates the dimensions of the model. -}
updateDimensions : Html.Extra.Dimensions -> Model -> Model
updateDimensions dimensions model =
  { model | dimensions = dimensions }

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
