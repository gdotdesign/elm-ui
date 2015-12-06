module Ext.Date where

import Array
import Date
import Native.DateTime

now : Date.Date
now =
  Native.DateTime.now Nothing

month : Date.Date -> Int
month date =
  Native.DateTime.month date

previousDay : Date.Date -> Date.Date
previousDay date =
  createDate (Date.year date) (month date) ((Date.day date) - 1)

nextDay : Date.Date -> Date.Date
nextDay date =
  createDate (Date.year date) (month date) ((Date.day date) + 1)

nextMonth : Date.Date -> Date.Date
nextMonth date =
  createDate (Date.year date) ((month date) + 1) (Date.day date)


previousMonth : Date.Date -> Date.Date
previousMonth date =
  createDate (Date.year date) (month date) 0


begginingOfMonth : Date.Date -> Date.Date
begginingOfMonth date =
  createDate (Date.year date) (month date) 1


endOfMonth : Date.Date -> Date.Date
endOfMonth date =
  createDate (Date.year date) ((month date) + 1) 0


createDate : Int -> Int -> Int -> Date.Date
createDate year month day =
  Native.DateTime.create year month day


daysInMonth : Date.Date -> Int
daysInMonth date =
  Native.DateTime.daysInMonth date


datesInMonth : Date.Date -> List Date.Date
datesInMonth date =
  let
    days =
      daysInMonth date

    create day =
      createDate (Date.year date) (month date) (day + 1)
  in
    Array.toList (Array.initialize days create)


isSameMonth : Date.Date -> Date.Date -> Bool
isSameMonth date other =
  (Date.year date) == (Date.year other)
  && (month date) == (month other)


isSameDate : Date.Date -> Date.Date -> Bool
isSameDate date other =
  (Date.year date) == (Date.year other)
  && (Date.day date) == (Date.day other)
  && (month date) == (month other)
