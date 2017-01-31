module Ui.DatePicker exposing
  ( Model, Msg, init, update, subscriptions, onChange, view, render, setValue
  , closeOnSelect )

{-| An input component that displays a **Calendar** (in a dropdown) when
focused, allowing the user to manipulate the selected date.

# Model
@docs Model, Msg, init, subscriptions, update

# DSL
@docs closeOnSelect

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html exposing (node, text)
import Html.Lazy

import Date.Extra.Format exposing (isoDateFormat, format)
import Date.Extra.Config.Configs as DateConfigs
import Time
import Date

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui.Helpers.Picker as Picker
import Ui.Native.Uid as Uid
import Ui.Calendar
import Ui.Icons
import Ui

import Ui.Styles.DatePicker exposing (defaultStyle)
import Ui.Styles

{-| Representation of a date picker:
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **format** - The format of the date to render in the input
  - **readonly** - Whether or not the date picker is readonly
  - **disabled** - Whether or not the date picker is disabled
  - **uid** - The unique identifier of the date picker
  - **calendar** - The model of the calendar
  - **dropdown** - The model of the dropdown
-}
type alias Model =
  { calendar : Ui.Calendar.Model
  , closeOnSelect : Bool
  , dropdown : Dropdown
  , format : String
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }


{-| Messages that a date picker can receive.
-}
type Msg
  = Calendar Ui.Calendar.Msg
  | Picker Picker.Msg
  | Select Time.Time
  | Increment
  | Decrement


{-| Initializes a date picker with the given date.

    datePicker =
      Ui.DatePicker.init ()
      |> Ui.DatePicker.closeOnSelect true
-}
init : () -> Model
init _ =
  { calendar = Ui.Calendar.init ()
  , dropdown = Dropdown.init
  , format = isoDateFormat
  , closeOnSelect = False
  , disabled = False
  , readonly = False
  , uid = Uid.uid ()
  }
    |> Dropdown.offset 5


{-| Subscribe to the changes of a date picker.

    subscriptions = Ui.DatePicker.onChange DatePickerChanged datePicker
-}
onChange : (Time.Time -> msg) -> Model -> Sub msg
onChange msg model =
  Ui.Calendar.onChange msg model.calendar


{-| Subscriptions for a date picker.

    subscriptions = Sub.map DatePicker (Ui.DatePicker.subscriptions datePicker)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Ui.Calendar.onChange Select model.calendar
    , Sub.map Picker (Picker.subscriptions model)
    ]


{-| Sets whether or not to close the dropdown when selecting an other date.
-}
closeOnSelect : Bool -> Model -> Model
closeOnSelect value model =
  { model | closeOnSelect = value }


{-| Updates a date picker.

    ( updatedDatePicker, cmd ) = Ui.DatePicker.update msg datePicker
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

    Picker act ->
      (Picker.update act model, Cmd.none)

    Decrement ->
      ( { model | calendar = Ui.Calendar.previousDay model.calendar }
          |> Dropdown.open
      , Cmd.none
      )

    Increment ->
      ( { model | calendar = Ui.Calendar.nextDay model.calendar }
          |> Dropdown.open
      , Cmd.none
      )


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
    dateText =
      (format (DateConfigs.getConfig locale) model.format model.calendar.value)
  in
    Picker.view
      { attributes = Ui.Styles.apply defaultStyle
      , address = Picker
      , keyActions =
        [ ( 40, Increment )
        , ( 38, Decrement )
        , ( 39, Increment )
        , ( 37, Decrement )
        ]
      , contents =
          [ node "ui-date-picker-content" [] [ text dateText ]
          , Ui.Icons.calendar []
          ]
      , dropdownContents =
        [ Html.map Calendar (Ui.Calendar.view locale model.calendar) ]
      } model


{-| Sets the value of a date picker

    ( updatedDatePicker, cmd ) =
      Ui.DatePicker.setValue (Ext.Date.create 1980 5 17) datePicker
-}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Ui.Calendar.setValue date model.calendar }
