module Ui.Calendar exposing
  ( Model, Msg, init, onChange, update, view, render, selectable
  , setValue, nextDay, previousDay )

{-| Simple calendar component:
  - Change month by clicking on arrows on the left or right in the header
  - Select a date by clicking on it
  - Can be rendered in a given locale

# Model
@docs Model, Msg, init, update

# DSL
@docs selectable

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue, nextDay, previousDay
-}

import Html exposing (node, text, span)
import Html.Events exposing (onClick)
import Html.Lazy

import Date.Extra.Config.Configs as DateConfigs
import Date.Extra.Format exposing (format)
import Time exposing (Time)
import Ext.Date
import Date

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Container
import Ui.Icons
import Ui

import Ui.Styles.Calendar exposing (defaultStyle)
import Ui.Styles

{-| Representation of a calendar component:
  - **selectable** - Whether or not the user can select a date by clicking on it
  - **disabled** - Whether or not the calendar is disabled
  - **readonly** - Whether or not the calendar is readonly
  - **uid** - The unique identifier of the calendar
  - **date** - The month which is displayed
  - **value** - The current selected date
-}
type alias Model =
  { selectable : Bool
  , value : Date.Date
  , date : Date.Date
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }


{-| Messages that a calendar can receive.
-}
type Msg
  = Select Date.Date
  | PreviousMonth
  | NextMonth


{-| Initializes a calendar.

    calendar = Ui.Calendar.init ()
-}
init : () -> Model
init _ =
  { value = Ext.Date.now ()
  , date = Ext.Date.now ()
  , selectable = True
  , disabled = False
  , readonly = False
  , uid = Uid.uid ()
  }


{-| Sets the selectable property of a calendar.
-}
selectable : Bool -> Model -> Model
selectable value model =
  { model | selectable = value }


{-| Subscribe to the changes of a calendar.

    subscription = Ui.Calendar.onChange CalendarChanged calendar
-}
onChange : (Time -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFloat model.uid msg


{-| Updates a calendar.

    ( updatedCalendar, cmd ) = Ui.Calendar.update msg calendar
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PreviousMonth ->
      ( { model | date = Ext.Date.previousMonth model.date }, Cmd.none )

    NextMonth ->
      ( { model | date = Ext.Date.nextMonth model.date }, Cmd.none )

    Select date ->
      if Ext.Date.isSameDate model.value date then
        ( model, Cmd.none )
      else
        ( { model | value = date }
        , Emitter.sendFloat model.uid (Date.toTime date)
        )


{-| Lazily renders a calendar in the given locale.

    Ui.Calendar.view "en_us" calendar
-}
view : String -> Model -> Html.Html Msg
view locale model =
  Html.Lazy.lazy2 render locale model


{-| Renders a calendar in the given locale.

    Ui.Calendar.render "en_us" calendar
-}
render : String -> Model -> Html.Html Msg
render locale model =
  let
    -- The date of the month
    month =
      Ext.Date.begginingOfMonth model.date

    -- List of dates in the month
    dates =
      Ext.Date.datesInMonth month

    -- The left padding in the table
    leftPadding =
      paddingLeft month

    -- The cells before the month
    paddingLeftItems =
      Ext.Date.previousMonth month
        |> Ext.Date.datesInMonth
        |> List.reverse
        |> List.take (paddingLeft month)
        |> List.reverse

    -- The cells after the month
    paddingRightItems =
      Ext.Date.nextMonth month
        |> Ext.Date.datesInMonth
        |> List.take (42 - leftPadding - (List.length dates))

    -- All of the 42 cells combined
    cells =
      paddingLeftItems
        ++ dates
        ++ paddingRightItems
        |> List.map (renderCell model)

    nextAction =
      Ui.enabledActions model [ onClick NextMonth ]

    previousAction =
      Ui.enabledActions model [ onClick PreviousMonth ]

    -- Header container
    container =
      Ui.Container.view
        { compact = True
        , align = "stretch"
        , direction = "row"
        }
        []
        [ Ui.Icons.chevronLeft previousAction
        , node "div" []
          [ text (format (DateConfigs.getConfig locale) "%Y - %B" month) ]
        , Ui.Icons.chevronRight nextAction
        ]
  in
    node
      "ui-calendar"
      ( [ Ui.attributeList
          [ ( "selectable", model.selectable )
          , ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ container
      , node "ui-calendar-header" []
        (List.map (\item -> span [] [ text item ]) (dayNames locale))
      , node "ui-calendar-table" [] cells
      ]


{-| Sets the value of a calendar.

    updatedCalendar =
      Ui.Calendar.setValue (Ext.Date.createDate 1977 5 25) calendar
-}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | value = date }
    |> fixDate


{-| Steps the selected value to the next day.
-}
nextDay : Model -> Model
nextDay model =
  { model | value = Ext.Date.nextDay model.value }
    |> fixDate


{-| Steps the selected value to the previous day.
-}
previousDay : Model -> Model
previousDay model =
  { model | value = Ext.Date.previousDay model.value }
    |> fixDate


{-| Fixes the date in order to make sure the selected date is visible.
-}
fixDate : Model -> Model
fixDate model =
  if Ext.Date.isSameMonth model.date model.value then
    model
  else
    { model | date = model.value }


{-| Returns the padding based on the day of the week.
-}
paddingLeft : Date.Date -> Int
paddingLeft date =
  case Date.dayOfWeek date of
    Date.Mon ->
      0

    Date.Tue ->
      1

    Date.Wed ->
      2

    Date.Thu ->
      3

    Date.Fri ->
      4

    Date.Sat ->
      5

    Date.Sun ->
      6


{-| Returns the short names of days.
-}
dayNames : String -> List String
dayNames locale =
  let
    config =
      DateConfigs.getConfig locale
        |> .i18n
  in
    [ Date.Mon
    , Date.Tue
    , Date.Wed
    , Date.Thu
    , Date.Fri
    , Date.Sat
    , Date.Sun
    ]
      |> List.map config.dayShort


{-| Renders a single cell.
-}
renderCell : Model -> Date.Date -> Html.Html Msg
renderCell model date =
  let
    sameMonth =
      Ext.Date.isSameMonth date model.date

    value =
      model.selectable && (Ext.Date.isSameDate date model.value)

    click =
      if not model.disabled
      && not model.readonly
      && model.selectable
      && sameMonth
      then
        [ onClick (Select date) ]
      else
        []

    attributes =
      Ui.attributeList
        [ ( "inactive", not sameMonth )
        , ( "selected", value )
        ]
  in
    node
      "ui-calendar-cell"
      (attributes ++ click)
      [ text (toString (Date.day date)) ]
