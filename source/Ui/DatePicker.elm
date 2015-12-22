module Ui.DatePicker
  (Model, Action, init, update, view, setValue) where

{-| Date picker input component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Extra exposing (onKeysWithDimensions, onWithDropdownDimensions)
import Html.Events exposing (onFocus, onBlur, onClick)
import Html.Attributes exposing (classList)
import Html exposing (node, div, text)
import Html.Lazy

import Signal exposing (forwardTo)
import Dict

import Date.Format exposing (format)
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar as Calendar
import Ui

{-| Representation of a date picker component:
  - **calendar** - The model of a calendar
  - **format** - The format of the date to render in the input
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **disabled** - Whether or not the chooser is disabled
  - **readonly** - Whether or not the dropdown is readonly
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { calendar : Calendar.Model
  , dropdownPosition : String
  , closeOnSelect : Bool
  , format : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a date picker can make:
  - **Focus** - Opens the dropdown
  - **Close** - Closes the dropdown
  - **Toggle** - Toggles the dropdown
  - **Decrement** - Selects the previous day
  - **Increment** - Selects the next day
  - **Calendar** - Calendar actions
-}
type Action
  = Focus Html.Extra.DropdownDimensions
  | Increment Html.Extra.DropdownDimensions
  | Decrement Html.Extra.DropdownDimensions
  | Close Html.Extra.DropdownDimensions
  | Toggle Html.Extra.DropdownDimensions
  | Calendar Calendar.Action
  | Blur

{-| Initializes a date picker with the given values.

    DatePicker.init date
-}
init : Date.Date -> Model
init date =
  { calendar = Calendar.init date
  , dropdownPosition = "bottom"
  , closeOnSelect = False
  , format = "%Y-%m-%d"
  , disabled = False
  , readonly = False
  , open = False
  }

{-| Updates a date picker. -}
update : Action -> Model -> Model
update action model =
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

    Calendar act ->
      let
        updatedModel =
          { model | calendar = Calendar.update act model.calendar }
      in
        case act of
          Calendar.Select date ->
            if model.closeOnSelect then
              Dropdown.close updatedModel
            else
              updatedModel
          _ -> updatedModel

{-| Renders a date picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a date picker.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    actions =
      if model.disabled || model.readonly then []
      else [ onWithDropdownDimensions "click" address Focus
           , onWithDropdownDimensions "focus" address Focus
           , onBlur address Blur
           , onKeysWithDimensions address
             (Dict.fromList [ (27, Close)
                            , (13, Toggle)
                            , (40, Increment)
                            , (38, Decrement)
                            , (39, Increment)
                            , (37, Decrement)
                            ])
           ]
  in
    node "ui-date-picker" ([ classList [ ("dropdown-open", model.open)
                                       , ("disabled", model.disabled)
                                       , ("readonly", model.readonly)
                                       ]
                           ] ++ actions ++ (Ui.tabIndex model))
      [ div [] [text (format model.format model.calendar.value)]
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
