module Ui.DatePicker
  (Model, Action, init, initWithAddress, update, view, setValue) where

{-| Date picker input component.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Extra exposing (onKeysWithDimensions, onWithDropdownDimensions)
import Html.Events exposing (onBlur, onClick)
import Html.Attributes exposing (classList)
import Html exposing (node, div, text)
import Html.Lazy

import Signal exposing (forwardTo)
import Ext.Signal
import Effects
import Dict

import Date.Format exposing (isoDateFormat, format)
import Date.Config.Configs as DateConfigs
import Time
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar as Calendar
import Ui

{-| Representation of a date picker component:
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **valueAddress** - The address to send the change in value
  - **format** - The format of the date to render in the input
  - **readonly** - Whether or not the date picker is readonly
  - **disabled** - Whether or not the date picker is disabled
  - **address** - The address to use for sub components
  - **open** - Whether or not the dropdown is open
  - **dropdownPosition** (internal) - The dropdowns position
  - **calendar** (internal) - The model of a calendar
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Time.Time)
  , address : Signal.Address Action
  , calendar : Calendar.Model
  , dropdownPosition : String
  , closeOnSelect : Bool
  , format : String
  , locale : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a date picker can make. -}
type Action
  = Increment Html.Extra.DropdownDimensions
  | Decrement Html.Extra.DropdownDimensions
  | Toggle Html.Extra.DropdownDimensions
  | Focus Html.Extra.DropdownDimensions
  | Close Html.Extra.DropdownDimensions
  | Calendar Calendar.Action
  | Select Time.Time
  | Tasks ()
  | Blur

{-| Initializes a date picker with the given values.

    DatePicker.init (forwardTo address DatePicker) date
-}
init : Signal.Address Action -> Date.Date -> Model
init address date =
  { address = address
  , valueAddress = Nothing
  , dropdownPosition = "bottom"
  , closeOnSelect = False
  , calendar = Calendar.init date
  , format = isoDateFormat
  , locale = "en_us"
  , disabled = False
  , readonly = False
  , open = False
  }

{-| Initializes a date picker with the given values and value address.

    DatePicker.init
      (forwardTo address DatePicker)
      (forwardTo address DatePickerChanged)
      date
-}
initWithAddress : Signal.Address Time.Time -> Signal.Address Action -> Date.Date -> Model
initWithAddress valueAddress address date =
  { address = address
  , valueAddress = Just valueAddress
  , dropdownPosition = "bottom"
  , closeOnSelect = False
  , calendar = Calendar.initWithAddress (forwardTo address Select) date
  , format = isoDateFormat
  , locale = "en_us"
  , disabled = False
  , readonly = False
  , open = False
  }

{-| Updates a date picker. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Calendar act ->
      let
        (calendar, effect) = Calendar.update act model.calendar
      in
        ({ model | calendar = calendar }, Effects.map Calendar effect)

    Select time ->
      let
        updatedModel =
          if model.closeOnSelect then
            Dropdown.close model
          else
            model
      in
        (updatedModel, Ext.Signal.sendAsEffect model.valueAddress time Tasks)

    _ ->
      (update' action model, Effects.none)

-- Effectless updates
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

    Decrement dimensions ->
      { model | calendar = Calendar.previousDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    Increment dimensions ->
      { model | calendar = Calendar.nextDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    _ -> model

{-| Renders a date picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a date picker.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    actions =
      Ui.enabledActions model
        [ onWithDropdownDimensions "focus" address Focus
        , onBlur address Blur
        , onKeysWithDimensions address [ (27, Close)
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
      , Dropdown.view model.dropdownPosition
        [ node "ui-dropdown-overlay" [onClick address Blur] []
        , Calendar.view (forwardTo address Calendar) model.calendar
        ]
      ]

{-| Sets the value of a date picker -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Calendar.setValue date model.calendar }
