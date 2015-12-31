module Ui.CalendarTests where

import ElmTest exposing (..)
import Ext.Date
import Date

import Ui.Calendar

tests : Test
tests =
  suite "Ui.Calendar"
    [ updatePreviousMonth
    , updateNextMonth
    ]

updatePreviousMonth : Test
updatePreviousMonth =
  let
    initial = Ui.Calendar.init (Date.fromTime 1430438400000)
    changed = Ui.Calendar.update Ui.Calendar.PreviousMonth initial
    expected = Date.fromTime 1427846400000
  in
    test "Should switch to previous month"
      (assertEqual (Ext.Date.isSameDate changed.date expected) True)

updateNextMonth : Test
updateNextMonth =
  let
    initial = Ui.Calendar.init (Date.fromTime 1430438400000)
    expected = Date.fromTime 1433116800000
    changed = Ui.Calendar.update Ui.Calendar.NextMonth initial
  in
    test "Should switch to next month"
      (assertEqual (Ext.Date.isSameDate changed.date expected) True)
