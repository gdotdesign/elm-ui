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
import Html.Extra exposing (onWithDropdownDimensions,onKeysWithDimensions)
import Html.Attributes exposing (classList, style)
import Html.Events exposing (onBlur, onClick)
import Html exposing (node, div, text)
import Html.Lazy

import Signal exposing (forwardTo)
import Ext.Color exposing (Hsv)
import Effects
import Color
import Dict

import Ui.Helpers.Dropdown as Dropdown
import Ui.ColorPanel as ColorPanel
import Ui

{-| Representation of a color picker:
  - **readonly** - Whether or not the color picker is readonly
  - **disabled** - Whether or not the color picker is disabled
  - **valueSignal** - The color pickers value as a signal
  - **open** - Whether or not the color picker is open
  - **dropdownPosition** (Internal) - Where the dropdown is positioned
  - **colorPanel** (internal) - The model of a color panel
-}
type alias Model =
  { colorPanel : ColorPanel.Model
  , dropdownPosition : String
  , valueSignal : Signal Hsv
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a color picker can make. -}
type Action
  = Toggle Html.Extra.DropdownDimensions
  | Focus Html.Extra.DropdownDimensions
  | Close Html.Extra.DropdownDimensions
  | ColorPanel ColorPanel.Action
  | ColorChanged Hsv
  | Blur

{-| Initializes a color picker with the given color.

    ColorPicker.init Color.yellow
-}
init : Color.Color -> Model
init color =
  let
    colorPanel = ColorPanel.init color
  in
    { valueSignal = colorPanel.valueSignal
    , dropdownPosition = "bottom"
    , colorPanel = colorPanel
    , disabled = False
    , readonly = False
    , open = False
    }

{-| Updates a color picker. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    ColorPanel act ->
      let
        (colorPanel, effect) = ColorPanel.update act model.colorPanel
      in
        ({ model | colorPanel = colorPanel }, Effects.map ColorPanel effect)

    _ ->
      (update' action model, Effects.none)

-- Effectless update
update' : Action -> Model -> Model
update' action model =
  case action of
    Focus dimensions ->
      Dropdown.openWithDimensions dimensions model

    Close _ ->
      Dropdown.close model

    Blur ->
      Dropdown.close model

    Toggle dimensions ->
      Dropdown.toggleWithDimensions dimensions model

    _ ->
      model

{-| Renders a color picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Updates a color picker by coordinates. -}
handleMove : Int -> Int -> Model -> (Model, Effects.Effects Action)
handleMove x y model =
  let
    (colorPanel, effect) = ColorPanel.handleMove x y model.colorPanel
  in
    ({ model | colorPanel = colorPanel }, Effects.map ColorPanel effect)

{-| Updates a color picker, stopping the drags if the mouse isnt pressed. -}
handleClick : Bool-> Model -> Model
handleClick pressed model =
  { model | colorPanel = ColorPanel.handleClick pressed model.colorPanel }

-- Render internal.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    color = Ext.Color.toCSSRgba model.colorPanel.value
    actions =
      Ui.enabledActions model
        [ onWithDropdownDimensions "focus" address Focus
        , onBlur address Blur
        , onKeysWithDimensions address [ (27, Close)
                                       , (13, Toggle)
                                       ]
        ]
  in
    node "ui-color-picker" ([ classList [ ("dropdown-open", model.open)
                                        , ("disabled", model.disabled)
                                        , ("readonly", model.readonly)
                                        ]
                            ] ++ actions ++ (Ui.tabIndex model))
      [ div [] [text color]
      , node "ui-color-picker-rect" []
        [ div [style [("background-color", color)]] [] ]
      , Dropdown.view model.dropdownPosition
        [ node "ui-dropdown-overlay" [onClick address Blur] []
        , ColorPanel.view (forwardTo address ColorPanel) model.colorPanel
        ]
      ]
