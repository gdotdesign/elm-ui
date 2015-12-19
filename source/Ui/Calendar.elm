module Ui.Calendar where

{-| This is a calendar component where the user
can select a date by clicking on it.

# Model
@docs Model, Action, init, update

# View
@docs view, render

# Functions
@docs setValue, nextDay, previousDay

# Private
@docs fixDate, renderCell,  paddingLeft
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onMouseDown)
import Html exposing (node, text)
import Html.Lazy
import List

import Date.Format exposing (format)
import Ext.Date
import Date

import Ui.Container
import Ui

{-| Representation of a calendar component:
  - **date** - The month in which this date is will be displayed
  - **value** - The current selected date
  - **selectable** - Whether the user can select a date by clicking
  - **disabled** - Whether the calendar is disabled
-}
type alias Model =
  { date : Date.Date
  , value : Date.Date
  , selectable : Bool
  , disabled : Bool
  }

{-| Actions that a calendar can make:
  - **NextMonth** - Steps the calendar to show next month
  - **PreviousMonth** - Steps the calendar to show previous month
  - **Select Date.Date** - Selects a date
-}
type Action
  = NextMonth
  | PreviousMonth
  | Select Date.Date

{-| Initializes a calendar with the given values.

    Calendar.init date
-}
init : Date.Date -> Model
init date =
  { date = date
  , value = date
  , selectable = True
  , disabled = False
  }

{-| Updates a calendar. -}
update : Action -> Model -> Model
update action model =
  case action of
    NextMonth ->
      { model | date = Ext.Date.nextMonth model.date }

    PreviousMonth ->
      { model | date = Ext.Date.previousMonth model.date }

    Select date ->
      { model | value = date }

{-| Renders a calendar (lazy). -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Renders a calendar. -}
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    {- The date of the month -}
    month =
      Ext.Date.begginingOfMonth model.date

    {- List of dates in the month -}
    dates =
      Ext.Date.datesInMonth month

    {- The left padding in the table -}
    leftPadding =
      paddingLeft month

    {- The cells before the month -}
    paddingLeftItems =
      Ext.Date.datesInMonth (Ext.Date.previousMonth month)
      |> List.reverse
      |> List.take (paddingLeft month)
      |> List.reverse

    {- The cells after the month -}
    paddingRightItems =
      Ext.Date.datesInMonth (Ext.Date.nextMonth month)
      |> List.take (42 - leftPadding - (List.length dates))

    {- All of the 42 cells combined -}
    cells =
      paddingLeftItems ++ dates ++ paddingRightItems
      |> List.map (\item -> renderCell address item model)

    {- Options for the container -}
    continerOptions =
      { align = "stretch"
      , direction = "row"
      , compact = False }

    nextAction =
      if model.disabled then []
      else [onMouseDown address NextMonth]

    previousAction =
      if model.disabled then []
      else [onMouseDown address PreviousMonth]

    {- Header container -}
    container =
      Ui.Container.view continerOptions []
        [ Ui.icon "chevron-left" True previousAction
        , node "div" [] [text (format "%Y - %B" month)]
        , Ui.icon "chevron-right" True nextAction
        ]
  in
    node "ui-calendar" [classList [("disabled", model.disabled)]]
      [ container
      , node "ui-calendar-table" [] cells ]

{-| Sets the value of a calendar -}
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

{-| Fixes the date in order to make sure the selected date is visible -}
fixDate : Model -> Model
fixDate model =
  if Ext.Date.isSameMonth model.date model.value then
    model
  else
    { model | date = model.value }

{-| Returns the padding based on the day of the week -}
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

{-| Renders a single cell -}
renderCell : Signal.Address Action -> Date.Date -> Model -> Html.Html
renderCell address date model =
  let
    sameMonth =
      Ext.Date.isSameMonth date model.date

    value =
      Ext.Date.isSameDate date model.value

    click =
      if model.selectable && sameMonth && not model.disabled then
        [onMouseDown address (Select date)]
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
