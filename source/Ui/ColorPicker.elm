module Ui.ColorPicker exposing
  (Model, Msg, init, subscribe, subscriptions, update, view, setValue)

--  where

{-| Color picker input component.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList, style)
import Html.Events exposing (onBlur, onClick)
import Html exposing (node, div, text)
import Html.App

import Ext.Color exposing (Hsv)
import Color exposing (Color)
import Dict

import Ui.Helpers.Dropdown as Dropdown
import Ui.ColorPanel
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
  { colorPanel : Ui.ColorPanel.Model
  , dropdownPosition : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a color picker can make. -}
type Msg
  = Toggle Dropdown.Dimensions
  | Focus Dropdown.Dimensions
  | Close Dropdown.Dimensions
  | ColorPanel Ui.ColorPanel.Msg
  | ColorChanged Hsv
  | Blur
  | NoOp

{-| Initializes a color picker with the given color.

    ColorPicker.init Color.yellow
-}
init : Color.Color -> Model
init color =
  { colorPanel = Ui.ColorPanel.init color
  , dropdownPosition = "bottom"
  , disabled = False
  , readonly = False
  , open = False
  }

subscribe model =
  Ui.ColorPanel.subscribe model.colorPanel

subscriptions =
  Sub.map ColorPanel Ui.ColorPanel.subscriptions

{-| Updates a color picker. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ColorPanel act ->
      let
        (colorPanel, effect) = Ui.ColorPanel.update act model.colorPanel
      in
        ({ model | colorPanel = colorPanel }, Cmd.map ColorPanel effect)

    _ ->
      (update' action model, Cmd.none)

-- Effectless update
update' : Msg -> Model -> Model
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
view : Model -> Html.Html Msg
view model =
  render model

{-| Sets the vale of a color picker. -}
setValue : Color -> Model -> Model
setValue color model =
  { model | colorPanel = Ui.ColorPanel.setValue color model.colorPanel }

-- Render internal.
render : Model -> Html.Html Msg
render model =
  let
    color =
      Ext.Color.toCSSRgba model.colorPanel.value

    actions =
      Ui.enabledActions model
        [ Dropdown.onWithDimensions "focus" Focus
        , onBlur Blur
        , Dropdown.onKeysWithDimensions [ (27, Close)
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
      , Dropdown.view NoOp model.dropdownPosition
        [ node "ui-dropdown-overlay" [onClick Blur] []
        , Html.App.map ColorPanel (Ui.ColorPanel.view model.colorPanel)
        ]
      ]
