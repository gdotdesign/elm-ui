module Date.Floor
  ( floor
  , Floor (..)
  ) where

{-| Reduce a date to a given granularity this is similar in concept
to floor on Float so was named the same.

This allows you to modify a date to reset to minimum values
all values below a given granularity.

This operates in local time zone so if you are not in UTC time zone
and you output date in UTC time zone the datefields will not be floored.

Example `Floor.floor Hour date` will return a modified date with
* Minutes to 0
* Seconds to 0
* Milliseconds to 0

@docs floor
@docs Floor

This modules implementation became much simpler when Field module was introduced.

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Date, Month (..))

import Date.Core as Core
import Date.Field as Field

{-| Date granularity of operations. -}
type Floor
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Month
  | Year


{-| Floor date by reducing to minimum value all values below given granularity.

This floors in local time zone values, as the date element parts
are pulled straight from the local time zone date values.
-}
floor : Floor -> Date -> Date
floor dateFloor date =
  case dateFloor of
    Millisecond -> date
    Second -> Field.fieldToDateClamp (Field.Millisecond 0) date
    Minute -> Field.fieldToDateClamp (Field.Second 0) (floor Second date)
    Hour -> Field.fieldToDateClamp (Field.Minute 0) (floor Minute date)
    Day -> Field.fieldToDateClamp (Field.Hour 0) (floor Hour date)
    Month -> Field.fieldToDateClamp (Field.DayOfMonth 1) (floor Day date)
    Year -> floorYear date


floorYear : Date -> Date
floorYear date =
  let
    startMonthDate = Field.fieldToDateClamp (Field.DayOfMonth 1) date
    startYearDate = Field.fieldToDateClamp (Field.Month Jan) startMonthDate
    monthTicks = (Core.toTime startMonthDate) - (Core.toTime startYearDate)
    updatedDate = Core.fromTime ((Core.toTime date) - monthTicks)
  in
    floor Month updatedDate
