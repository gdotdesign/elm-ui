module Ui.DatePicker where

{-| Date picker input component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Attributes exposing (value, readonly, classList, disabled)
import Html.Events exposing (onFocus, onBlur, onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, input)

import Signal exposing (forwardTo)
import Native.Browser
import Dict

import Date.Format exposing (format)
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar as Calendar

{-| Representation of a date picker component:
  - **calendar** - The model of a calendar
  - **format** - The format of the date to render in the input
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **disabled** - Whether or not the chooser is disabled
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { calendar : Calendar.Model
  , closeOnSelect : Bool
  , format : String
  , open : Bool
  , disabled : Bool
  }

{-| Actions that a date picker can make:
  - **Focus** - Opens the dropdown
  - **Close** - Closes the dropdown
  - **Decrement** - Selects the previous day
  - **Increment** - Selects the next day
  - **Calendar** - Calendar actions
-}
type Action
  = Focus
  | Nothing
  | Increment
  | Decrement
  | Close
  | Calendar Calendar.Action

{-| Initializes a date picker with the given values.

    DatePicker.init date
-}
init : Date.Date -> Model
init date =
  { calendar = Calendar.init date
  , closeOnSelect = False
  , format = "%Y-%m-%d"
  , open = False
  , disabled = False
  }

{-| Updates a date picker. -}
update : Action -> Model -> Model
update action model =
  case action of
    Focus ->
      Dropdown.open model

    Close ->
      Dropdown.close model

    Decrement ->
      { model | calendar = Calendar.previousDay model.calendar }
        |> Dropdown.open

    Increment ->
      { model | calendar = Calendar.nextDay model.calendar }
        |> Dropdown.open

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

    _ -> model

{-| Renders a date picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  node "ui-date-picker" [ classList [ ("dropdown-open", model.open)
                                    , ("disabled", model.disabled)
                                    ]
                        ]
    [ input
      [ onFocus address Focus
      , disabled model.disabled
      , onClick address Focus
      , onBlur address Close
      , readonly True
      , value (format model.format model.calendar.value)
      , onKeys address Nothing (Dict.fromList [ (27, Close)
                                              , (13, Close)
                                              , (40, Increment)
                                              , (38, Decrement)
                                              , (39, Increment)
                                              , (37, Decrement)
                                              ])
      ] []
    , Dropdown.view []
      [ node "ui-dropdown-overlay" [onClick address Close] []
      , Calendar.view (forwardTo address Calendar) model.calendar
      ]
    ]

{-| Sets the value of a date picker -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Calendar.setValue date model.calendar }
