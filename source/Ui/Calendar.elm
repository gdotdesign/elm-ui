module Ui.Calendar exposing
  ( Model, Msg(..), init, subscribe, update, view, setValue, nextDay
  , previousDay ) -- where

{-| This is a calendar component where the user can:
  - Select a date by clicking on it
  - Change the month with arrows

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view

# Functions
@docs setValue, nextDay, previousDay
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onMouseDown)
import Html exposing (node, text, span)
import Html.Lazy

import Date.Format exposing (isoDateFormat, format)
import Date.Config.Configs as DateConfigs
import Time exposing (Time)
import Json.Decode as JD
import Json.Encode as JE
import Native.Uid
import Ext.Date
import List
import Date

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui

{-| Representation of a calendar component:
  - **selectable** - Whether or not the user can select a date by clicking
  - **readonly** - Whether or not the calendar is interactive
  - **disabled** - Whether or not the calendar is disabled
  - **value** - The current selected date
  - **date** (internal) - The month in which this date is will be displayed
  - **uid** - The unique identifier of the calendar
-}
type alias Model =
  { selectable : Bool
  , value : Date.Date
  , date : Date.Date
  , disabled : Bool
  , readonly : Bool
  , locale : String
  , uid : String
  }

{-| Actions that a calendar can make. -}
type Msg
  = Select Date.Date
  | PreviousMonth
  | NextMonth
  | Tasks ()

{-| Initializes a calendar with the given value.

    Calendar.init date
-}
init : Date.Date -> Model
init date =
  { uid = Native.Uid.uid ()
  , selectable = True
  , disabled = False
  , readonly = False
  , value = date
  , date = date
  , locale = "en_us"
  }

{-| Subscribe to the changes of a calendar.
-}
subscribe : (Time -> msg) -> Model -> Sub msg
subscribe action model =
  Emitter.listen model.uid (Emitter.decode JD.float 0 action)

{-| Updates a calendar. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    NextMonth ->
      ({ model | date = Ext.Date.nextMonth model.date }, Cmd.none)

    PreviousMonth ->
      ({ model | date = Ext.Date.previousMonth model.date }, Cmd.none)

    Select date ->
      if Ext.Date.isSameDate model.value date then
        (model, Cmd.none)
      else
        ({ model | value = date }
         , Emitter.send model.uid (JE.float (Date.toTime date)))

    Tasks _ ->
      (model, Cmd.none)

{-| Renders a calendar. -}
view :Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model

-- Render internal
render : Model -> Html.Html Msg
render model =
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
      Ext.Date.datesInMonth (Ext.Date.previousMonth month)
      |> List.reverse
      |> List.take (paddingLeft month)
      |> List.reverse

    -- The cells after the month -
    paddingRightItems =
      Ext.Date.datesInMonth (Ext.Date.nextMonth month)
      |> List.take (42 - leftPadding - (List.length dates))

    -- All of the 42 cells combined --
    cells =
      paddingLeftItems ++ dates ++ paddingRightItems
      |> List.map (\item -> renderCell item model)

    nextAction =
      Ui.enabledActions model [ onMouseDown NextMonth ]

    previousAction =
      Ui.enabledActions model [ onMouseDown PreviousMonth ]

    {- Header container -}
    container =
      Ui.Container.view { compact = True
                        , align = "stretch"
                        , direction = "row" } []
        [ Ui.icon "chevron-left" (not model.readonly) previousAction
        , node "div" [] [text (format (DateConfigs.getConfig model.locale) "%Y - %B" month)]
        , Ui.icon "chevron-right" (not model.readonly) nextAction
        ]
  in
    node "ui-calendar" [classList [ ("disabled", model.disabled)
                                  , ("readonly", model.readonly)
                                  , ("selectable", model.selectable)
                                  ]
                       ]
      [ container
      , node "ui-calendar-header" []
        (List.map (\item -> span [] [text item]) dayNames)
      , node "ui-calendar-table" [] cells
      ]

{-| Sets the value of a calendar. -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | value = date }
    |> fixDate

{-| Steps the selected value to the next day -}
nextDay : Model -> Model
nextDay model =
  { model | value = Ext.Date.nextDay model.value }
    |> fixDate

{-| Steps the selected value to the preivous day -}
previousDay : Model -> Model
previousDay model =
  { model | value = Ext.Date.previousDay model.value }
    |> fixDate

-- Fixes the date in order to make sure the selected date is visible
fixDate : Model -> Model
fixDate model =
  if Ext.Date.isSameMonth model.date model.value then
    model
  else
    { model | date = model.value }

-- Returns the padding based on the day of the week
paddingLeft : Date.Date -> Int
paddingLeft date =
  case Date.dayOfWeek date of
    Date.Mon -> 0
    Date.Tue -> 1
    Date.Wed -> 2
    Date.Thu -> 3
    Date.Fri -> 4
    Date.Sat -> 5
    Date.Sun -> 6

-- Short names of days
dayNames : List String
dayNames =
  ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

-- Renders a single cell
renderCell : Date.Date -> Model -> Html.Html Msg
renderCell date model =
  let
    sameMonth =
      Ext.Date.isSameMonth date model.date

    value =
      Ext.Date.isSameDate date model.value

    click =
      if model.selectable && sameMonth &&
         not model.disabled && not model.readonly then
        [onMouseDown (Select date)]
      else
        []

    classes =
      classList [ ("selected", value )
                , ("inactive", not sameMonth)
                ]
  in
    node "ui-calendar-cell"
         ([classes] ++ click)
         [text (toString (Date.day date))]
