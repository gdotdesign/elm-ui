module Ui.DatePicker exposing
  (Model, Msg, init, update, view, setValue)

-- where

{-| Date picker input component.

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Events exposing (onBlur, onClick)
import Html.Attributes exposing (classList)
import Html exposing (node, div, text)
import Html.App

import Dict

import Date.Format exposing (isoDateFormat, format)
import Date.Config.Configs as DateConfigs
import Time
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar
import Ui

{-| Representation of a date picker component:
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **format** - The format of the date to render in the input
  - **readonly** - Whether or not the date picker is readonly
  - **disabled** - Whether or not the date picker is disabled
  - **address** - The address to use for sub components
  - **open** - Whether or not the dropdown is open
  - **dropdownPosition** (internal) - The dropdowns position
  - **calendar** (internal) - The model of a calendar
-}
type alias Model =
  { calendar : Ui.Calendar.Model
  , dropdownPosition : String
  , closeOnSelect : Bool
  , format : String
  , locale : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a date picker can make. -}
type Msg
  = Increment Dropdown.Dimensions
  | Decrement Dropdown.Dimensions
  | Toggle Dropdown.Dimensions
  | Focus Dropdown.Dimensions
  | Close Dropdown.Dimensions
  | Calendar Ui.Calendar.Msg
  | Select Time.Time
  | Tasks ()
  | NoOp
  | Blur

{-| Initializes a date picker with the given values.

    DatePicker.init (forwardTo address DatePicker) date
-}
init : Date.Date -> Model
init date =
  { dropdownPosition = "bottom"
  , closeOnSelect = False
  , calendar = Ui.Calendar.init date
  , format = isoDateFormat
  , locale = "en_us"
  , disabled = False
  , readonly = False
  , open = False
  }

subscribe model =
  Ui.Calendar.subscribe model.colorPanel

subscriptions model =
  Ui.Calendar.subscribe Select model.calendar

{-| Updates a date picker. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Calendar act ->
      let
        (calendar, effect) = Ui.Calendar.update act model.calendar
      in
        ({ model | calendar = calendar }, Cmd.map Calendar effect)

    Select time ->
      let
        updatedModel =
          if model.closeOnSelect then
            Dropdown.close model
          else
            model
      in
        (updatedModel, Cmd.none)

    _ ->
      (update' action model, Cmd.none)

-- Effectless updates
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

    Decrement dimensions ->
      { model | calendar = Ui.Calendar.previousDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    Increment dimensions ->
      { model | calendar = Ui.Calendar.nextDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    _ -> model

{-| Renders a date picker. -}
view : Model -> Html.Html Msg
view model =
  render model

-- Renders a date picker.
render : Model -> Html.Html Msg
render model =
  let
    actions =
      Ui.enabledActions model
        [ Dropdown.onWithDimensions "focus" Focus
        , onBlur Blur
        , Dropdown.onKeysWithDimensions [ (27, Close)
                                                , (13, Toggle)
                                                , (40, Increment)
                                                , (38, Decrement)
                                                , (39, Increment)
                                                , (37, Decrement)
                                                ]
        ]
  in
    node "ui-date-picker" ([ classList [ ("dropdown-open", model.open)
                                       , ("disabled", model.disabled)
                                       , ("readonly", model.readonly)
                                       ]
                           ] ++ actions ++ (Ui.tabIndex model))
      [ div [] [text (format (DateConfigs.getConfig model.locale) model.format model.calendar.value)]
      , Ui.icon "calendar" False []
      , Dropdown.view NoOp model.dropdownPosition
        [ node "ui-dropdown-overlay" [onClick Blur] []
        , Html.App.map Calendar (Ui.Calendar.view model.calendar)
        ]
      ]

{-| Sets the value of a date picker -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Ui.Calendar.setValue date model.calendar }
