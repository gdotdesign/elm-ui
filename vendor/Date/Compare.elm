module Date.Compare
  ( is
  , is3
  , Compare2 (..)
  , Compare3 (..)
  ) where

{-| Compare dates.

@docs is
@docs is3
@docs Compare2
@docs Compare3

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Date)

import Date.Core as Core


{-| Date comparison type for 2 dates.

* After
 * Return True if date1 is after date2.
* Before
 * Return True if date1 is before date2.
* Same
 * Return True if date1 is same as date2.
* SameOrAfter
 * Return True if date1 is same or after date2.
* SameOrBefore
 * Return True if date1 is same or before date2.
-}
type Compare2
  = After
  | Before
  | Same
  | SameOrAfter
  | SameOrBefore


{-| Date comparison type for 3 dates.

Between does not care if date2 > date3 or date2 < date3.

* Between
 * Return True if date1 is After date2 and Before date3
 * Return True if date1 is After date3 and Before date2
* BetweenOpenStart
 * Return True if date1 is SameOrAfter date2 and Before date3
* BetweenOpenEnd
 * Return True if date1 is After date2 and SameOrBefore date3
* BetweenOpen
 * Return True if date1 is SameOrAfter date2 and SameOrBefore date3
-}
type Compare3
  = Between
  | BetweenOpenStart
  | BetweenOpenEnd
  | BetweenOpen


{-| Compare two dates.
-}
is : Compare2 -> Date -> Date -> Bool
is comp date1 date2 =
  let
    time1 = Core.toTime date1
    time2 = Core.toTime date2
  in
    case comp of
      Before ->
        time1 < time2
      After ->
        time1 > time2
      Same ->
        time1 == time2
      SameOrBefore ->
        time1 <= time2
      SameOrAfter ->
        time1 >= time2


{-| Compare three dates.

This figures out the low and high bounds from date2
and date3 using minimum and maximum of them respectively.
-}
is3 : Compare3 -> Date -> Date -> Date -> Bool
is3 comp date1 date2 date3=
  let
    time1 = Core.toTime date1
    time2 = Core.toTime date2
    time3 = Core.toTime date3
    highBound = max time2 time3
    lowBound = min time2 time3
  in
    case comp of
      Between ->
        time1 > lowBound && time1 < highBound
      BetweenOpenStart ->
        time1 >= lowBound && time1 < highBound
      BetweenOpenEnd ->
        time1 > lowBound && time1 <= highBound
      BetweenOpen ->
        time1 >= lowBound && time1 <= highBound
