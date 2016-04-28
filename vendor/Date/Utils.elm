module Date.Utils
  ( fromString
  , unsafeFromString
  , dayList
  , isoWeek
  , isoWeekOne
  , timeFromFields
  , dateFromFields
  ) where

{-| Date Utils.

## Date parsing
@docs fromString
@docs dateFromFields
@docs timeFromFields

**Be careful with unsafeFromString it will Debug.crash() if it cant parse date.**
@docs unsafeFromString

## Utility
@docs dayList
@docs isoWeek
@docs isoWeekOne

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Day (..), Date, Month (..))
import Regex
import String
import Time

import Date.Create as Create
import Date.Core as Core
import Date.Field as Field
import Date.Format as Format
import Date.Internal as Internal
import Date.Period as Period
import Date.Floor as Floor
import Date.Compare as Compare exposing (is, Compare2 (..))


{-| Return a list of days dayLength long for successive days
starting from startDate.
-}
dayList : Int -> Date -> List (Date)
dayList dayLength startDate =
  List.reverse (dayList' dayLength startDate [])


dayList' : Int -> Date -> List (Date) -> List (Date)
dayList' dayLength date list =
  if dayLength == 0 then
    list
  else
    dayList'
      (dayLength - 1)
      -- (addDays 1 date)
      (Period.add Period.Day 1 date)
      (date :: list)


{-| Return iso week values year, week, isoDayOfWeek. -}
isoWeek : Date -> (Int, Int, Int)
isoWeek date =
  let
    inputYear = Date.year date
    endOfYearMaxIsoWeekDate = unsafeFromString ((toString inputYear) ++ "/12/29")
    (year, week1) =
      if is SameOrAfter date endOfYearMaxIsoWeekDate then
        let
          nextYearIsoWeek1 = isoWeekOne (inputYear + 1)
          -- _ = Debug.log("isoWeek") ("nextYearIsoWeek1", inputYear + 1, Format.isoString nextYearIsoWeek1)
        in
          if is Before date nextYearIsoWeek1 then
            (inputYear, isoWeekOne inputYear)
          else
            (inputYear + 1, nextYearIsoWeek1)
      else
        let
          thisYearIsoWeek1 = isoWeekOne inputYear
          -- _ = Debug.log("isoWeek") ("thisYearIsoWeek1", inputYear, Format.utcFormat.isoString thisYearIsoWeek1)
        in
          if is Before date thisYearIsoWeek1 then
            (inputYear - 1, isoWeekOne (inputYear - 1))
          else
            (inputYear, thisYearIsoWeek1)
    dateAsDay = Floor.floor Floor.Day date
    daysSinceWeek1 = (Core.toTime dateAsDay - (Core.toTime week1)) // Core.ticksADay
  in
    (year, (daysSinceWeek1 // 7) + 1, Core.isoDayOfWeek (Date.dayOfWeek date))


{- Reference point for isoWeekOne. -}
isoDayofWeekMonday = Core.isoDayOfWeek Date.Mon

{-| Return date of start of week one for year. -}
isoWeekOne : Int -> Date
isoWeekOne year =
  let
    date = unsafeFromString ((toString year) ++ "/01/04")
    isoDow = Core.isoDayOfWeek (Date.dayOfWeek date)
  in
    Period.add Period.Day (isoDayofWeekMonday - isoDow) date


{-| Elm Date.fromString suffers from the some of the same javascript unusual
compensation of input ranges when converting strings to Dates.

This method makes some known undesirable no Err results return Err.

Example produces `Ok "2012-03-02"` in javascript
```
  aDate = (Date.fromString "2012-02-31")
```

checkDateResult tries to catch and mark as Err some of these cases.
-}
fromString : String -> Result String Date
fromString dateStr =
  (Date.fromString dateStr)
    `Result.andThen`
    (checkDateResult dateStr)


{-| Utility for known input string date creation cases.
Checks for a fail just in case and calls Debug.crash().
-}
unsafeFromString : String -> Date
unsafeFromString dateStr =
  case fromString dateStr of
    Ok date -> date
    Err msg -> Debug.crash("unsafeFromString")


{- If the input string is UTC based ends in "Z" or "+00:00"
check that rendering date to string again after is in utc form.
Otherwise we check rendering of date in local form matches date part.

Regex currently limited to "-" between date parts only.
-}
checkDateResult : String -> Date -> Result String Date
checkDateResult dateStr date =
    let
      -- we only check for extra logic if dateStr matches this regex
      extraCheck = Regex.regex "^\\d{4}-\\d{1,2}-\\d{1,2}"
      endsWithUTCOffset =
           String.endsWith "Z" dateStr
        || String.endsWith "+00:00" dateStr
        || String.endsWith "+0000" dateStr
        || String.endsWith "+00" dateStr
      checkDatePart =
        if endsWithUTCOffset then
          Format.utcIsoDateString date
        else
          Format.isoDateString date
    in
      if Regex.contains extraCheck dateStr then
        if String.startsWith checkDatePart dateStr then
          Ok date
        else
          Err
          ( "Error leading date part got converted from \""
            ++ dateStr ++ "\" to \""
            ++ checkDatePart ++ "\""
          )
      else
        Ok date


{-| Create a date in current time zone from given fields.
All field values are clamped to there allowed range values.
This can only return dates in current time zone.

Hours are input in 24 hour time range 0 to 23 valid.
-}
dateFromFields : Int -> Month -> Int -> Int -> Int -> Int -> Int -> Date
dateFromFields year month day hour minute second millisecond =
  Date.fromTime 0
    |> Field.fieldToDateClamp (Field.Year year)
    |> Field.fieldToDateClamp (Field.Month month)
    |> Field.fieldToDateClamp (Field.DayOfMonth day)
    |> Field.fieldToDateClamp (Field.Hour hour)
    |> Field.fieldToDateClamp (Field.Minute minute)
    |> Field.fieldToDateClamp (Field.Second second)
    |> Field.fieldToDateClamp (Field.Millisecond millisecond)


{-| Create a time in current time zone from given fields, for
when you dont care about the date part but need time part anyway.

All field values are clamped to there allowed range values.
This can only return dates in current time zone.

Hours are input in 24 hour time range 0 to 23 valid.

This defaults to year 1970, month Jan, day of month 1 for date part.
-}
timeFromFields : Int -> Int -> Int -> Int -> Date
timeFromFields =
  dateFromFields 1970 Jan 1
