module BDate where

{-| Another Date, many functions. Though experiment around a type ?

Copyright (c) 2016 Robin Luiten
-}


{-| BDate

Queries
* From Noda Time using ticks it can represent years in range
 * 27000 BCE to around 31000 CE Gregorian
 * Arbitrarily going to BDate to +-9999 ?

BDate Constructors
* Instant
 * ticks since epoch, no offset, no zone, no calendar
 * for when something happened

-}
type BDate
  = Instant Int
  | LocalDate
  | LocalDateTime
  | BOffset Int Int -- offset, ticks
  | BZoned String -- timezone string

-- Think need seperate types, not Constructors under one type or cannot
-- limit API by type for inputs etc.



{-

IDEA:

case myDate of
  split date into parts.... in pattern

A record might be better can match on just field names wanted ?
- though it still does work of pulling it all apart

Joda-Time features:
* LocalDate - date without time
type LocalDateTime = ?

type LocalDate = ?

* LocalTime - time without date
type LocalTime = ?

* Instant - an instantaneous point on the time-line
type Instant = ?

* DateTime - full date and time with time-zone
type DateTime = ?

* DateTimeZone - a better time-zone
type DateTimeZone = ?

* Duration and Period - amounts of time

type Duration = ? -- its fixed time periods no Month, Year Stuff.
type Period = ? -- calendar based periods

* Interval - the time between two instants

* A comprehensive and flexible formatter-parser


Periods for actions on
  LocalDateTime, LocalDate LocalTime

Durations for actions on
  Intant, ZonedDateTime

  work fine but ZoneDatetime if you add time
  to something that moves into or out of daylight
  saving your answer isnt obvious....

  Then comparison betwen the types as needed
  by allowing typed parameters.


  Pull in tz database (olson database)
  Not sure format yet. maybe Decoder ?

-}







{-
-- Bunch of create date functions, do not use date as input.

{- Make a local date from year, rest fields default. -}
makeDateY : { a | year : Int} -> Date
makeDateY {year} =
  unsafeFromString ""


-- input idea ? "1981,Dec,32,12,23,55,333,-600" - urk parse.

-- custom records for this stuff ?
-- unique entry points or all.

makeDateAllOffset :
  { a
  | year : Int
  , month : Month
  , day : Day
  , hour : Int
  , minute : Int
  , second : Int
  , millisecond : Int
  , offsetMinutes : Int
  }
  -> Date
makeDateAllOffset {year,month,day,hour,minute,second,millisecond,offsetMinutes} =
  unsafeFromString ""

-- makeDate {year, month} =


type alias DateRec =
  { year : Int
  , month : Month
  , day : Day
  , hour : Int
  , minute : Int
  , second : Int
  , millisecond : Int
  , offsetMinutes : Int
  }


epochAsRecord : DateRec
epochAsRecord =
  { year = 1970
  , month = Jan
  , day = Thu
  , hour = 0
  , minute = 0
  , second = 0
  , millisecond = 0
  , offsetMinutes = 0
  }

-}
