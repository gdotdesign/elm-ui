module Ui.Ratings (Model, Action(..), init, update, view, setValue) where

{-| A simple star rating component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue
-}
import Effects
import Signal
import Array

import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Html.Attributes exposing (classList)
import Html.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ui

{-| Representation of a ratings component.
  - **disabled** - Whether or not the component is disabled
  - **readonly** - Whether or not the component is readonly
  - **value** - The current value of the component (0..1)
  - **size** - The number of starts to display
-}
type alias Model =
  { mailbox : Signal.Mailbox Float
  , hoverValue : Float
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

{-| Initializes a ratings component with the given number of stars and initial
value.

    Ratings.init 10 0.1 -- 1 out of 10 star rating
-}
init : Int -> Float -> Model
init size value =
  { mailbox = Signal.mailbox value
  , hoverValue = value
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
      setValue (clamp 0 1 (model.value - (1 / (toFloat model.size)))) model
    Click index ->
      setValue (calculateValue index model) model

{-| Renders a ratings component. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Sets the value of a ratings component. -}
setValue : Float -> Model -> (Model, Effects.Effects Action)
setValue value model =
  ({ model | value = value
           , hoverValue = value }, Effects.none)

-- Calculates the value for the given index
calculateValue : Int -> Model -> Float
calculateValue index model =
  clamp 0 1 ((toFloat index) / (toFloat model.size))

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
