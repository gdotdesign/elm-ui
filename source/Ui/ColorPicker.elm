module Ui.ColorPicker where

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

type alias Model =
  { colorPanel : ColorPanel.Model
  , disabled : Bool
  , open : Bool
  }

type Action
  = Focus
  | Nothing
  | Close
  | Toggle
  | Increment
  | Decrement
  | ColorPanel ColorPanel.Action

init : Color.Color -> Model
init color =
  { colorPanel = ColorPanel.init color
  , disabled = False
  , open = False
  }

{-| Updates a date picker. -}
update : Action -> Model -> Model
update action model =
  case action of
    Focus ->
      Dropdown.open model

    Close ->
      Dropdown.close model

    Toggle ->
      Dropdown.toggle model

    Decrement ->
      model
        |> Dropdown.open

    Increment ->
      model
        |> Dropdown.open

    ColorPanel act ->
      { model | colorPanel = ColorPanel.update act model.colorPanel }

    _ -> model

handleMove : Int -> Int -> Model -> Model
handleMove x y model =
  { model | colorPanel = ColorPanel.handleMove x y model.colorPanel }

handleClick : Bool-> Model -> Model
handleClick pressed model =
  { model | colorPanel = ColorPanel.handleClick pressed model.colorPanel }

view : Signal.Address Action -> Model -> Html.Html
view address model =
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
                                              , (40, Increment)
                                              , (38, Decrement)
                                              , (39, Increment)
                                              , (37, Decrement)
                                              ])
      ] []
    , Dropdown.view []
      [ node "ui-dropdown-overlay" [onClick address Close] []
      , ColorPanel.view (forwardTo address ColorPanel) model.colorPanel
      ]
    ]
