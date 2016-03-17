module Ui.Ratings
  ( Model, Action, init, initWithAddress, update, view, setValue
  , valueAsStars, setAndSendValue) where

{-| A simple star rating component.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs setValue, setAndSendValue, valueAsStars
-}
import Ext.Number exposing (roundTo)
import Ext.Signal
import Effects
import Signal
import Array

import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Html.Attributes exposing (classList)
import Html.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ui

import Debug exposing (log)

{-| Representation of a ratings component.
  - **clearable** - Whether or not the component is clearable
  - **disabled** - Whether or not the component is disabled
  - **readonly** - Whether or not the component is readonly
  - **valueAddress** - The address to send changes in value
  - **value** - The current value of the component (0..1)
  - **size** - The number of starts to display
  - **hoverValue** (internal) - The transient value of the component
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Float)
  , hoverValue : Float
  , clearable : Bool
  , disabled : Bool
  , readonly : Bool
  , value : Float
  , size : Int
  }

{-| Actions that a ratings component can make. -}
type Action
  = MouseEnter Int
  | MouseLeave
  | Increment
  | Decrement
  | Click Int
  | Tasks ()

{-| Initializes a ratings component with the given number of stars and initial
value.

    -- 1 out of 10 star rating
    Ratings.init 10 0.1
-}
init : Int -> Float -> Model
init size value =
  { valueAddress = Nothing
  , hoverValue = value
  , clearable = False
  , disabled = False
  , readonly = False
  , value = value
  , size = size
  }

{-| Initializes a ratings component with the given number of stars, initial
value and value address.

    -- 1 out of 10 star rating
    Ratings.init (forwardTo adress RatingsChanged) 10 0.1
-}
initWithAddress : Signal.Address Float -> Int -> Float -> Model
initWithAddress valueAddress size value =
  let
    model = init size value
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a ratings component. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    MouseEnter index ->
      ({ model | hoverValue = calculateValue index model }, Effects.none)

    MouseLeave ->
      ({ model | hoverValue = model.value }, Effects.none)

    Increment ->
      setAndSendValue (clamp 0 1 (model.value + (1 / (toFloat model.size)))) model

    Decrement ->
      let
        oneStarValue = 1 / (toFloat model.size)
        min = if model.clearable then 0 else oneStarValue
      in
        setAndSendValue (clamp oneStarValue 1 (model.value - oneStarValue)) model

    Click index ->
      setAndSendValue (calculateValue index model) model

    Tasks _ ->
      (model, Effects.none)

{-| Renders a ratings component. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Sets the value of a ratings component. -}
setValue : Float -> Model -> Model
setValue value' model =
  let
    value = roundTo 2 value'
  in
    if model.value == value
    && model.hoverValue == value
    then
      model
    else
      { model | value = value
              , hoverValue = value }

{-| Sets the given value and sends it to the value address. -}
setAndSendValue : Float -> Model -> (Model, Effects.Effects Action)
setAndSendValue value model =
  let
    updatedModel = setValue value model
  in
    if model.value == updatedModel.value then
      (model, Effects.none)
    else
      sendValue updatedModel

{-| Sends the value to the value address as an effect. -}
sendValue : Model -> (Model, Effects.Effects Action)
sendValue model =
  (model, Ext.Signal.sendAsEffect model.valueAddress model.value Tasks)

{-| Returns the value of a ratings component as number of stars. -}
valueAsStars : Float -> Model -> Int
valueAsStars value model =
  round (value * (toFloat model.size))

-- Calculates the value for the given index
calculateValue : Int -> Model -> Float
calculateValue index model =
  let
    value =
      clamp 0 1 ((toFloat index) / (toFloat model.size))

    currentIndex =
      valueAsStars model.value model
  in
    if currentIndex == index && model.clearable then 0 else value

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    actions =
      Ui.enabledActions model
        [onKeys address [ (40, Decrement)
                        , (38, Increment)
                        , (37, Decrement)
                        , (39, Increment)
                        ]
        ]

    stars =
      Array.initialize model.size ((+) 1)
      |> Array.toList
  in
    node "ui-ratings" ([classList [ ("disabled", model.disabled)
                                  , ("readonly", model.readonly)]
                       ] ++ (Ui.tabIndex model) ++ actions)
      (List.map (renderStar address model) stars)

-- Renders a star
renderStar : Signal.Address Action -> Model -> Int -> Html.Html
renderStar address model index =
  let
    actions =
      Ui.enabledActions model
        [ onClick address (Click index)
        , onMouseEnter address (MouseEnter index)
        , onMouseLeave address MouseLeave
        ]

    class =
      if ((toFloat index) / (toFloat model.size)) <= model.hoverValue then
        "ui-ratings-full"
      else
        "ui-ratings-empty"
  in
    node "ui-ratings-star"
      ([classList [ (class, True)]
       ] ++ actions)
      []
