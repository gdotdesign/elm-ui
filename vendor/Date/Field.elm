module Date.Field
  ( fieldToDate
  , fieldToDateClamp
  , Field (..)
  ) where

{-| Setting a date field on a date.

@docs fieldToDate
@docs fieldToDateClamp
@docs Field

-}

import Date exposing (Date, Day, Month)

import Date.Core as Core
import Date.Duration as Duration


{-| Configured Field and Value to set on date.

All field values are applied Modulus there maximum value.


* DayOfWeek
 * The week keeps the same start of week day as passed in and changes day.
* Month
 * Will not change year only the month of year.

-}
type Field
  = Millisecond Int
  | Second Int
  | Minute Int
  | Hour Int
  | DayOfWeek (Day, Day) -- (Target Day, Start of Weekday)
  | DayOfMonth Int
  | Month Month
  | Year Int


{-| Set a field on a date to a specific value.

If your value in field is out side of valid range for
the date field this function will return Nothing.

* DayOfWeek cannot be invalid input range
* Month cannot be invalid

Valid ranges
* Millisecond 0 to 999
* Second 0 to 59
* Minute 0 to 59
* Hour 0 to 23
* DayOfMonth 1 to max day of month for year
* Year >= 0

-}
fieldToDate : Field -> Date -> Maybe Date
fieldToDate field date =
  case field of
    Millisecond millisecond ->
      if millisecond < 0 || millisecond > 999 then
        Nothing
      else
        Just <| Duration.add Duration.Millisecond (millisecond - Date.millisecond date) date

    Second second ->
      if second < 0 || second > 59 then
        Nothing
      else
        Just <| Duration.add Duration.Second (second - Date.second date) date

    Minute minute ->
      if minute < 0 || minute > 59 then
        Nothing
      else
        Just <| Duration.add Duration.Minute (minute - Date.minute date) date

    Hour hour ->
      if hour < 0 || hour > 23 then
        Nothing
      else
        Just <| Duration.add Duration.Hour (hour - Date.hour date) date

    -- Inputs can't be out of range so Nothing is never returned
    DayOfWeek (newDayOfWeek, startOfWeekDay) -> -- Just date
      Just <| dayOfWeekToDate newDayOfWeek startOfWeekDay date

    DayOfMonth day ->
      let
        maxDays = Core.daysInMonthDate date
      in
        if day < 1 || day > maxDays then
          Nothing
        else
          Just <| Duration.add Duration.Day (day - Date.day date) date

    -- Inputs can't be out of range so Nothing is never returned.
    Month month ->
      Just <| monthToDate month date

    Year year ->
      if year < 0 then
        Nothing
      else
        Just <| Duration.add Duration.Year (year - (Date.year date)) date


monthToDate month date =
  let
    targetMonthInt = Core.monthToInt month
    monthInt = Core.monthToInt (Date.month date)
  in
    Duration.add Duration.Month (targetMonthInt - monthInt) date


dayOfWeekToDate newDayOfWeek startOfWeekDay date =
  let
    dayOfWeek = Date.dayOfWeek date
    daysToStartOfWeek = Core.daysBackToStartOfWeek dayOfWeek startOfWeekDay
    targetIsoDay = Core.isoDayOfWeek newDayOfWeek
    isoDay = Core.isoDayOfWeek dayOfWeek
    dayDiff = targetIsoDay - isoDay
    -- _ = Debug.log("dayOfWeekToDate") (daysToStartOfWeek, dayDiff)
    adjustedDiff =
      if (daysToStartOfWeek + dayDiff) < 0 then
        dayDiff + 7
      else
        dayDiff
  in
    Duration.add Duration.Day adjustedDiff date


{-|  Set a field on a date to a specific value.

This version clamps any input Field values to valid ranges as
described in the doc for fieldToDate function.
-}
fieldToDateClamp : Field -> Date -> Date
fieldToDateClamp field date =
  case field of
    Millisecond millisecond ->
      Duration.add Duration.Millisecond (clamp 0 999 millisecond - Date.millisecond date) date

    Second second ->
      Duration.add Duration.Second (clamp 0 59 second - Date.second date) date

    Minute minute ->
      Duration.add Duration.Minute (clamp 0 59 minute - Date.minute date) date

    Hour hour ->
      Duration.add Duration.Hour (clamp 0 23 hour - Date.hour date) date

    DayOfWeek (newDayOfWeek, startOfWeekDay) ->
      dayOfWeekToDate newDayOfWeek startOfWeekDay date

    DayOfMonth day ->
      let
        maxDays = Core.daysInMonthDate date
      in
        Duration.add Duration.Day (clamp 1 maxDays day - Date.day date) date

    Month month ->
      monthToDate month date

    Year year ->
      let
        minYear = if year < 0 then 0 else year
      in
        Duration.add Duration.Year (minYear - (Date.year date)) date
