module Ui.Checkbox
  (Model, Action, init, update, setValue, view, toggleView, radioView) where

{-| Checkbox component.

# Model
@docs Model, Action, init, update

# Views
@docs view, toggleView, radioView

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList, tabindex)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy
import Dict

import Ui

{-| Representation of a checkbox. -}
type alias Model =
  { disabled : Bool
  , readonly : Bool
  , value : Bool
  }

{-| Actions that a checkbox can make:
  - **Toggle** - Changes the value to the opposite
-}
type Action
  = Toggle

{-| Initiaizes a checkbox with the given value. -}
init : Bool -> Model
init value =
  { disabled = False
  , readonly = False
  , value = value
  }

{-| Updates a checkbox. -}
update : Action -> Model -> Model
update action model =
  case action of
    Toggle ->
      { model | value = not model.value }

{-| Sets the value of a checkbox to the given one. -}
setValue : Bool -> Model -> Model
setValue value model =
  { model | value = value }

{-| Renders a checkbox. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-checkbox"
    (attributes address model)
    [Ui.icon "checkmark" False []]

{-| Renders a checkbox as a radio. -}
radioView : Signal.Address Action -> Model -> Html.Html
radioView address model =
  Html.Lazy.lazy2 radioRender address model

-- Render radio internal.
radioRender : Signal.Address Action -> Model -> Html.Html
radioRender address model =
  node "ui-checkbox-radio"
    (attributes address model)
    [ node "ui-checkbox-radio-circle" [] []
    ]

{-| Renders a checkbox as a toggle. -}
toggleView : Signal.Address Action -> Model -> Html.Html
toggleView address model =
  Html.Lazy.lazy2 toggleRender address model

-- Render toggle internal.
toggleRender : Signal.Address Action -> Model -> Html.Html
toggleRender address model =
  node "ui-checkbox-toggle"
    (attributes address model)
    [ node "ui-checkbox-toggle-bg" [] []
    , node "ui-checkbox-toggle-handle" [] []
    ]

{- Returns attributes for a checkbox -}
attributes : Signal.Address Action -> Model -> List Html.Attribute
attributes address model =
  let
    actions =
      if model.disabled || model.readonly then []
      else
        [ onClick address Toggle
        , onKeys address
          (Dict.fromList [ (13, Toggle)
                         , (32, Toggle)
                         ])]
  in
    [ classList [ ("disabled", model.disabled)
                , ("readonly", model.readonly)
                , ("checked", model.value) ]
    ] ++ (Ui.tabIndex model) ++ actions
