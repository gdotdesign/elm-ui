module Ui.Checkbox
  (Model, Action, init, update, setValue, view, toggleView) where

{-| Checkbox component.

# Model
@docs Model, Action, init, update

# Views
@docs view, toggleView

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList, tabindex)
import Html.Extra exposing (onKeys, onTouch)
import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Lazy
import Dict

import Ui

{-| Representation of a checkbox. -}
type alias Model =
  { disabled : Bool
  , value : Bool
  }

{-| Actions that a checkbox can make:
  - **Toggle** - Changes the value to the opposite
-}
type Action
  = Toggle
  | Nothing

{-| Initiaizes a checkbox with the given value. -}
init : Bool -> Model
init value =
  { disabled = False
  , value = value
  }

{-| Updates a checkbox. -}
update : Action -> Model -> Model
update action model =
  case action of
    Toggle ->
      { model | value = not model.value }
    Nothing ->
      model

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
  [ classList [ ("disabled", model.disabled)
              , ("checked", model.value) ]
  , onClick address Toggle
  , onKeys address Nothing (Dict.fromList [ (13, Toggle)
                                          , (32, Toggle)
                                          ])
  ] ++ (Ui.tabIndex model)
