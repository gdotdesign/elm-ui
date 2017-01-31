module Ext.Date exposing (..)

{-| This module provides utility functions to Date using Native functions.

# Create
@docs now, nowTime, createDate

# Querying
@docs month, daysInMonth, datesInMonth

# Manipulation
@docs previousDay, nextDay, previousMonth, nextMonth, begginingOfMonth
@docs endOfMonth

# Testing
@docs isSameMonth, isSameDate

# Formatting
@docs ago
-}

import Time exposing (Time)
import Native.DateTime
import Array
import Date

{-| Returns the current date.

    Ext.Date.now ()
-}
now : () -> Date.Date
now _ =
  Native.DateTime.now Nothing


{-| Returns the current date as time.

    Ext.Date.nowTime ()
-}
nowTime : () -> Time
nowTime _ =
  Date.toTime (now ())


{-| Creates a date from the given year, month and day.

    Ext.Date.createDate 2015 1 1
-}
createDate : Int -> Int -> Int -> Date.Date
createDate year month day =
  Native.DateTime.create year month day


{-| Returns the month from the given date.

    Ext.Date.month (Ext.Date.createDate 2015 1 1) -- 1
-}
month : Date.Date -> Int
month date =
  Native.DateTime.month date


{-| Returns how many days are in the month of the given date.

    Ext.Date.daysInMonth (Ext.Date.createDate 2015 1 1) -- 31
-}
daysInMonth : Date.Date -> Int
daysInMonth date =
  Native.DateTime.daysInMonth date


{-| Return the dates in the month of the given date.

    Ext.Date.datesInMonth (Ext.Date.createDate 2015 1 1)
    -- [ 2015-01-01, 2015-02-02, ... ]
-}
datesInMonth : Date.Date -> List Date.Date
datesInMonth date =
  let
    create day =
      createDate (Date.year date) (month date) (day + 1)
  in
    Array.toList (Array.initialize (daysInMonth date) create)


{-| Returns the previous days date in relation to the given date.

    Ext.Date.previousDay (Ext.Date.createDate 2015 1 1) -- 2014-12-31
-}
previousDay : Date.Date -> Date.Date
previousDay date =
  createDate (Date.year date) (month date) ((Date.day date) - 1)


{-| Returns the next days date in relation to the given date.

    Ext.Date.nextDay (Ext.Date.createDate 2015 1 1) -- 2015-01-02
-}
nextDay : Date.Date -> Date.Date
nextDay date =
  createDate (Date.year date) (month date) ((Date.day date) + 1)


{-| Returns the next month date in relation to the given date.

    Ext.Date.nextMonth (Ext.Date.createDate 2015 1 5) -- 2015-02-05
-}
nextMonth : Date.Date -> Date.Date
nextMonth date =
  createDate (Date.year date) ((month date) + 1) (Date.day date)
    |> begginingOfMonth


{-| Returns the previous month date in relation to the given date.

    Ext.Date.previousMonth (Ext.Date.createDate 2015 1 5) -- 2014-12-05
-}
previousMonth : Date.Date -> Date.Date
previousMonth date =
  createDate (Date.year date) (month date) 0
    |> begginingOfMonth


{-| Returns the first date in of the month of the given date.

    Ext.Date.begginingOfMonth (Ext.Date.createDate 2015 1 5) -- 2015-01-01
-}
begginingOfMonth : Date.Date -> Date.Date
begginingOfMonth date =
  createDate (Date.year date) (month date) 1


{-| Returns the last date in of the month of the given date.

    Ext.Date.endOfMonth (Ext.Date.createDate 2015 1 5) -- 2015-01-31
-}
endOfMonth : Date.Date -> Date.Date
endOfMonth date =
  createDate (Date.year date) ((month date) + 1) 0


{-| Tests if the given dates are in the same month.
-}
isSameMonth : Date.Date -> Date.Date -> Bool
isSameMonth date other =
  (Date.year date)
    == (Date.year other)
    && (month date)
    == (month other)


{-| Tests if the given dates are the same.
-}
isSameDate : Date.Date -> Date.Date -> Bool
isSameDate date other =
  (Date.year date)
    == (Date.year other)
    && (Date.day date)
    == (Date.day other)
    && (month date)
    == (month other)


{-| Returns the date in relative format.
-}
ago : Date.Date -> Date.Date -> String
ago date other =
  let
    seconds =
      ((Date.toTime other) - (Date.toTime date)) / 1000

    year =
      floor (seconds / 31536000)

    month =
      floor (seconds / 2592000)

    day =
      floor (seconds / 86400)

    hour =
      floor (seconds / 3600)

    minute =
      floor (seconds / 60)

    format number affix =
      let
        prefix =
          if affix == "hour" then
            "an"
          else
            "a"
      in
        if number < 2 then
          prefix ++ " " ++ affix
        else
          (toString number) ++ " " ++ affix ++ "s"

    value =
      if year >= 1 then
        format year "year"
      else if month >= 1 then
        format month "month"
      else if day >= 1 then
        format day "day"
      else if hour >= 1 then
        format hour "hour"
      else if minute >= 1 then
        format minute "minute"
      else
        format (floor seconds) "second"
  in
    if minute > 0 then
      if seconds > 0 then
        value ++ " ago"
      else
        "in " ++ value
    else
      "just now"
