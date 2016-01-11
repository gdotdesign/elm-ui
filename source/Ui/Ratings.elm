module Ui.Ratings
  (Model, Action, init, update, view, setValue, valueAsStars) where

{-| A simple star rating component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue, valueAsStars
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
  - **value** - The current value of the component (0..1)
  - **valueSignal** - The componens value as a signal
  - **size** - The number of starts to display
  - **hoverValue** (internal) - The transient value of the component
  - **mailbox** (internal) - The mailbox of the component
-}
type alias Model =
  { mailbox : Signal.Mailbox Float
  , valueSignal : Signal Float
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

    Ratings.init 10 0.1 -- 1 out of 10 star rating
-}
init : Int -> Float -> Model
init size value =
  let
    mailbox = Signal.mailbox value
  in
    { valueSignal = Signal.dropRepeats mailbox.signal
    , hoverValue = value
    , mailbox = mailbox
    , clearable = False
    , disabled = False
    , readonly = False
    , value = value
    , size = size
    }

{-| Updates a ratings component. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    MouseEnter index ->
      ({ model | hoverValue = calculateValue index model }, Effects.none)

    MouseLeave ->
      ({ model | hoverValue = model.value }, Effects.none)

    Increment ->
      setValue (clamp 0 1 (model.value + (1 / (toFloat model.size)))) model

    Decrement ->
      let
        oneStarValue = 1 / (toFloat model.size)
        min = if model.clearable then 0 else oneStarValue
      in
        setValue (clamp oneStarValue 1 (model.value - oneStarValue)) model

    Click index ->
      setValue (calculateValue index model) model

    Tasks _ ->
      (model, Effects.none)

{-| Renders a ratings component. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Sets the value of a ratings component. -}
setValue : Float -> Model -> (Model, Effects.Effects Action)
setValue value' model =
  let
    value =
      roundTo 2 value'

    updatedModel =
      { model | value = value
              , hoverValue = value }

    effect =
      Ext.Signal.sendAsEffect
        model.mailbox.address
        value
        Tasks
  in
    (updatedModel, effect)

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
