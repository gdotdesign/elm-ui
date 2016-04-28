module Date.Create exposing
  ( makeDateTicks
  , getTimezoneOffset
  )

{-| Create dates and offsets.

@docs makeDateTicks
@docs getTimezoneOffset

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Date, Month (..))

import Date.Core as Core


{-| Return raw epoch ticks since Unix epoch for given date.
Result can be positive or negative.
Unix epoch. Thursday, 1 January 1970 at 00:00:00.000 in UTC is 0 ticks.

This can be fed to Date.fromTime to create a time, but be careful this
function does nothing about time zone offsets so you may not get you
would expect.

TODO ? not sure should pass in Date as source of the parameters, it is
missleading as to whats doing the work this way I think. It also means
the date offset has an impact...
-}
makeDateTicks : Date -> Int
makeDateTicks date =
  let
    year = Date.year date
  in
    if year < 1970 then
      makeDateTicksNegative date
    else
      makeDateTicksPositive date


makeDateTicksPositive date =
  let
    year = Date.year date
    month = Date.month date
    day = Date.day date
    restTicks
      = (Date.millisecond date) * Core.ticksAMillisecond
      + (Date.second date) * Core.ticksASecond
      + (Date.minute date) * Core.ticksAMinute
      + (Date.hour date) * Core.ticksAnHour
      + (day - 1) * Core.ticksADay -- day of month is 1 based
    yearTicks = getYearTicksFrom1970 year
    monthTicks = getMonthTicksSinceStartOfYear year month
  in
    yearTicks + monthTicks + restTicks


{- Return the ticks for start of year since unix epoch (1970). -}
getYearTicksFrom1970 year =
  iterateSum ((+)1) yearToTicks year 1970 0


yearToTicks year =
  (Core.yearToDayLength year) * Core.ticksADay

{- Return days in year upto start of given year and month. -}
getMonthTicksSinceStartOfYear : Int -> Month -> Int
getMonthTicksSinceStartOfYear year month =
  iterateSum Core.nextMonth (monthToTicks year) month Jan 0


{- Return ticks in a given year month. -}
monthToTicks : Int -> Month -> Int
monthToTicks year month =
  (Core.daysInMonth year month) * Core.ticksADay


makeDateTicksNegative date =
  let
    year = Date.year date
    month = Date.month date
    yearTicks = getYearTicksTo1970 year
    monthTicks = getMonthTicksToEndYear year month
    daysToEndOfMonth = (Core.daysInMonth year month) - (Date.day date)
    dayTicks = daysToEndOfMonth * Core.ticksADay
    hoursToEndOfDay = 24 - (Date.hour date) - 1
    hourTicks = hoursToEndOfDay * Core.ticksAnHour
    minutesToEndOfHour = 60 - (Date.minute date) - 1
    minuteTicks = minutesToEndOfHour * Core.ticksAMinute
    secondsToEndOfMinute = 60 - (Date.second date) - 1
    secondTicks = secondsToEndOfMinute * Core.ticksASecond
    millisecondsToEndOfSecond = 1000 - (Date.millisecond date)
    millisecondTicks = millisecondsToEndOfSecond * Core.ticksAMillisecond
    -- _ = Debug.log("makeDateTicksNegative element counts")
    --   ( year, month
    --   , (Date.day date, daysToEndOfMonth)
    --   , (Date.hour date, hoursToEndOfDay)
    --   , (Date.minute date, minutesToEndOfHour)
    --   , (Date.second date, secondsToEndOfMinute)
    --   , (Date.millisecond date, millisecondsToEndOfSecond)
    --   )
    -- _ = Debug.log("makeDateTicksNegative ticks")
    --   ( (yearTicks, yearTicks // Core.ticksADay)
    --   , (monthTicks, monthTicks // Core.ticksADay), dayTicks
    --   , hourTicks, minuteTicks, secondTicks, millisecondTicks)
  in
    negate (yearTicks + monthTicks + dayTicks
      + hourTicks + minuteTicks + secondTicks + millisecondTicks)


{- Return days to end of year, end of Dec.
This does not include days in the starting month given.
-}
getMonthTicksToEndYear year month =
  iterateSum
    Core.nextMonth (monthToTicks year) Jan
    (Core.nextMonth month) 0


{- Return the ticks for start of year up to unix epoch (1970).
Note if our date is in a given year we start counting full years after it.
-}
getYearTicksTo1970 year =
  iterateSum ((+)1) yearToTicks 1970 (year + 1) 0

{-|  A general iterate for sum accumulator.
-}
iterateSum : (a -> a) -> (a -> number) -> a -> a -> number -> number
iterateSum getNext getValue target current accumulator =
  if current == target then
    accumulator
  else
    iterateSum getNext getValue target
      (getNext current) (accumulator + (getValue current))


{-| Return the time zone offset of current javascript environment underneath
Elm in Minutes. This should produce the same result getTimezoneOffset()
for a given date in the same javascript VM.

Time zone offset is always for a given date and time so an input date is required.

Given that timezones change (though slowly) this is not strictly pure, but
I suspect it is sufficiently pure. Is is dependent on the timezone mechanics
of the javascript VM.


### Example zone stuff.
For an offset of -600 minutes, in +10:00 time zone offset.

In javascript date parsing of "1970-01-01T00:00:00Z" produces a
javascript localised date.

Converting this date to a string in javascript
* toISOString()  produces "1970-01-01T00:00:00.000Z"
* toLocalString() produces "01/01/1970, 10:00:00"

The 10 in hours field due to the +10:00 offset.
Thats how the time zone offset can be figured out, by creating the date
using makeDateTicks

The offset is picked up in Elm using makeDateTicks which creates a
UTC date in ticks from the fields pulled from the date we want to
compare with.
-}
getTimezoneOffset : Date -> Int
getTimezoneOffset date =
  let
    date =
      {-
        DO NOT USE `DateUtils.fromString` or `DateUtils.usafeFromString` here.
        It will cause unbounded recursion and give interesting javascript
        console errors about functions not existing.
      -}
      case (Date.fromString Core.epochDateStr) of
        Ok aDate -> aDate
        Err _ -> Debug.crash("Failed to parse unix epoch date something is very wrong.")

    dateTicks = Core.toTime date
    newTicks = makeDateTicks date
    timezoneOffset = (dateTicks - newTicks) // Core.ticksAMinute
    -- _ = Debug.log("Date.Create getTimezoneOffset") (timezoneOffset)
  in
    timezoneOffset
