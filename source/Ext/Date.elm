module Ext.Date where

{-| Utility functions for dates.

# Create
@docs now, createDate

# Querying
@docs month, daysInMonth, datesInMonth

# Manipulation
@docs previousDay, nextDay, previousMonth, nextMonth, begginingOfMonth
@docs endOfMonth

# Testing
@docs isSameMonth, isSameDate
-}

import Native.DateTime
import Array
import Date

{-| Returns the current date. -}
now : Date.Date
now =
  Native.DateTime.now Nothing

{-| Creates a date from the given year, month and day.

    createDate 2015 1 1
-}
createDate : Int -> Int -> Int -> Date.Date
createDate year month day =
  Native.DateTime.create year month day

{-| Returns the month from the given date.

    month (createDate 2015 1 1) -- 1
-}
month : Date.Date -> Int
month date =
  Native.DateTime.month date

{-| Returns how many days are in the month of the given date.

    daysInMonth (createDate 2015 1 1) -- 31
-}
daysInMonth : Date.Date -> Int
daysInMonth date =
  Native.DateTime.daysInMonth date

{-| Return the dates in the month of the given date.

    datesInMonth (createDate 2015 1 1) -- [2015-01-01,2015-02-02,...]
-}
datesInMonth : Date.Date -> List Date.Date
datesInMonth date =
  let
    create day =
      createDate (Date.year date) (month date) (day + 1)
  in
    Array.toList (Array.initialize (daysInMonth date) create)

{-| Returns the previous days date in relation to the given date.

    previousDay (createDate 2015 1 1) -- 2014-12-31
-}
previousDay : Date.Date -> Date.Date
previousDay date =
  createDate (Date.year date) (month date) ((Date.day date) - 1)

{-| Returns the next days date in relation to the given date.

    nextDay (createDate 2015 1 1) -- 2015-01-02
-}
nextDay : Date.Date -> Date.Date
nextDay date =
  createDate (Date.year date) (month date) ((Date.day date) + 1)

{-| Returns the next month date in relation to the given date.

    nextMonth (createDate 2015 1 5) -- 2015-02-05
-}
nextMonth : Date.Date -> Date.Date
nextMonth date =
  createDate (Date.year date) ((month date) + 1) (Date.day date)
    |> begginingOfMonth

{-| Returns the previous month date in relation to the given date.

    previousMonth (createDate 2015 1 5) -- 2014-12-05
-}
previousMonth : Date.Date -> Date.Date
previousMonth date =
  createDate (Date.year date) (month date) 0
    |> begginingOfMonth

{-| Returns the first date in of the month of the given date.

    begginingOfMonth (createDate 2015 1 5) -- 2015-01-01
-}
begginingOfMonth : Date.Date -> Date.Date
begginingOfMonth date =
  createDate (Date.year date) (month date) 1

{-| Returns the last date in of the month of the given date.

    endOfMonth (createDate 2015 1 5) -- 2015-01-31
-}
endOfMonth : Date.Date -> Date.Date
endOfMonth date =
  createDate (Date.year date) ((month date) + 1) 0

{-| Tests if the given dates are in the same month. -}
isSameMonth : Date.Date -> Date.Date -> Bool
isSameMonth date other =
  (Date.year date) == (Date.year other)
  && (month date) == (month other)

{-| Tests if the given dates are in the same. -}
isSameDate : Date.Date -> Date.Date -> Bool
isSameDate date other =
  (Date.year date) == (Date.year other)
  && (Date.day date) == (Date.day other)
  && (month date) == (month other)
