module Ui.ColorPicker
  (Model, Action, init, update, view, handleMove, handleClick) where

{-| Color picker input component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs handleMove, handleClick
-}
import Html.Attributes exposing (value, readonly, classList, disabled)
import Html.Events exposing (onFocus, onBlur, onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, input)
import Html.Lazy

import Signal exposing (forwardTo)
import Ext.Color
import Color
import Dict

import Ui.Helpers.Dropdown as Dropdown
import Ui.ColorPanel as ColorPanel

{-| Representation of a color picker:
  - **colorPanel** (internal) - The model of a color panel
  - **disabled** - Whether or not the color picker is disabled
  - **open** - Whether or not the color picker is open
-}
type alias Model =
  { colorPanel : ColorPanel.Model
  , disabled : Bool
  , open : Bool
  }

{-| Actions that a color picker can make. -}
type Action
  = Focus
  | Nothing
  | Close
  | Toggle
  | ColorPanel ColorPanel.Action

{-| Initializes a color picker with the given color.

    ColorPicker.init Color.yellow
-}
init : Color.Color -> Model
init color =
  { colorPanel = ColorPanel.init color
  , disabled = False
  , open = False
  }

{-| Updates a color picker. -}
update : Action -> Model -> Model
update action model =
  case action of
    Focus ->
      Dropdown.open model

    Close ->
      Dropdown.close model

    Toggle ->
      Dropdown.toggle model

    ColorPanel act ->
      { model | colorPanel = ColorPanel.update act model.colorPanel }

    _ -> model

{-| Renders a color picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Updates a color picker by coordinates. -}
handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  { model | colorPanel = ColorPanel.handleMove x y model.colorPanel }

{-| Updates a color picker, stopping the drags if the mouse isnt pressed. -}
handleClick : Bool-> Model -> Model
handleClick pressed model =
  { model | colorPanel = ColorPanel.handleClick pressed model.colorPanel }

-- Render internal.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-color-picker" [ classList [ ("dropdown-open", model.open)
                                     , ("disabled", model.disabled)
                                     ]
                        ]
    [ input
      [ onFocus address Focus
      , disabled model.disabled
      , onClick address Focus
      , onBlur address Close
      , readonly True
      , value (Ext.Color.toCSSRgba model.colorPanel.value)
      , onKeys address Nothing (Dict.fromList [ (27, Close)
                                              , (13, Toggle)
                                              ])
      ] []
    , Dropdown.view []
      [ node "ui-dropdown-overlay" [onClick address Close] []
      , ColorPanel.view (forwardTo address ColorPanel) model.colorPanel
      ]
    ]
