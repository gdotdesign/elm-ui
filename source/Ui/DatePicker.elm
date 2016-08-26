module Ui.DatePicker exposing
  (Model, Msg, init, update, subscribe, subscriptions, view, render, setValue)

{-| An input component that displays a **Calendar** (in a dropdown) when
focused, allowing the user to manipulate the selected date.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Events exposing (onBlur, onClick)
import Html.Attributes exposing (classList)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node, div, text)
import Html.Lazy
import Html.App

import Date.Extra.Format exposing (isoDateFormat, format)
import Date.Extra.Config.Configs as DateConfigs
import Time
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar
import Ui


{-| Representation of a date picker:
  - **calendar** - The model of a calendar
  - **dropdownPosition** - The dropdowns position
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **format** - The format of the date to render in the input
  - **readonly** - Whether or not the date picker is readonly
  - **disabled** - Whether or not the date picker is disabled
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { calendar : Ui.Calendar.Model
  , dropdownPosition : String
  , closeOnSelect : Bool
  , format : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }


{-| Messages that a date picker can receive.
-}
type Msg
  = Increment Dropdown.Dimensions
  | Decrement Dropdown.Dimensions
  | Toggle Dropdown.Dimensions
  | Focus Dropdown.Dimensions
  | Close Dropdown.Dimensions
  | Calendar Ui.Calendar.Msg
  | Select Time.Time
  | NoOp
  | Blur


{-| Initializes a date picker with the given date.

    datePicker = Ui.DatePicker.init (Ext.Date.create 1980 5 17)
-}
init : Date.Date -> Model
init date =
  { calendar = Ui.Calendar.init date
  , dropdownPosition = "bottom"
  , format = isoDateFormat
  , closeOnSelect = False
  , disabled = False
  , readonly = False
  , open = False
  }


{-| Subscribe to the changes of a date picker.

    ...
    subscriptions =
      \model ->
        Ui.DatePicker.subscribe
          DatePickerChanged
          model.datePicker
    ...
-}
subscribe : (Time.Time -> msg) -> Model -> Sub msg
subscribe msg model =
  Ui.Calendar.subscribe msg model.calendar


{-| Subscriptions for a date picker.

    ...
    subscriptions =
      \model ->
        Sub.map
          DatePicker
          (Ui.DatePicker.subscriptions model.datePicker)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Ui.Calendar.subscribe Select model.calendar


{-| Updates a date picker.

    Ui.DatePicker.update msg datePicker
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Calendar act ->
      let
        ( calendar, effect ) =
          Ui.Calendar.update act model.calendar
      in
        ( { model | calendar = calendar }, Cmd.map Calendar effect )

    Select time ->
      let
        updatedModel =
          if model.closeOnSelect then
            Dropdown.close model
          else
            model
      in
        ( updatedModel, Cmd.none )

    Focus dimensions ->
      ( Dropdown.openWithDimensions dimensions model, Cmd.none )

    Close _ ->
      ( Dropdown.close model, Cmd.none )

    Blur ->
      ( Dropdown.close model, Cmd.none )

    Toggle dimensions ->
      ( Dropdown.toggleWithDimensions dimensions model, Cmd.none )

    Decrement dimensions ->
      ( { model | calendar = Ui.Calendar.previousDay model.calendar }
          |> Dropdown.openWithDimensions dimensions
      , Cmd.none
      )

    Increment dimensions ->
      ( { model | calendar = Ui.Calendar.nextDay model.calendar }
          |> Dropdown.openWithDimensions dimensions
      , Cmd.none
      )

    NoOp ->
      ( model, Cmd.none )


{-| Lazily renders a date picker in the given locale.

    Ui.DatePicker.view "en_us" model
-}
view : String -> Model -> Html.Html Msg
view locale model =
  Html.Lazy.lazy2 render locale model


{-| Renders a date picker in the given locale.

    Ui.DatePicker.render "en_us" model
-}
render : String -> Model -> Html.Html Msg
render locale model =
  let
    actions =
      Ui.enabledActions
        model
        [ Dropdown.onWithDimensions "focus" Focus
        , Dropdown.onWithDimensions "mousedown" Toggle
        , onBlur Blur
        , Dropdown.onKeysWithDimensions
            [ ( 27, Close )
            , ( 13, Toggle )
            , ( 40, Increment )
            , ( 38, Decrement )
            , ( 39, Increment )
            , ( 37, Decrement )
            ]
        ]

    open =
      model.open && not model.disabled && not model.readonly
  in
    node
      "ui-date-picker"
      ([ classList
          [ ( "dropdown-open", open )
          , ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
       ]
        ++ actions
        ++ (Ui.tabIndex model)
      )
      [ div [] [ text (format (DateConfigs.getConfig locale) model.format model.calendar.value) ]
      , Ui.icon "calendar" False []
      , Dropdown.view
          NoOp
          model.dropdownPosition
          [ node "ui-dropdown-overlay" [ onClick Blur ] []
          , Html.App.map Calendar (Ui.Calendar.view locale model.calendar)
          ]
      ]


{-| Sets the value of a date picker

    Ui.DatePicker.setValue (Ext.Date.create 1980 5 17) datePicker
-}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Ui.Calendar.setValue date model.calendar }
