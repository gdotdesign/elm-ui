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
    , previousDay
    , nextDay
    ]

mailbox : Signal.Mailbox Float
mailbox =
  Signal.mailbox 0

nextDay : Test
nextDay =
  let
    initial = Ui.Calendar.init mailbox.address (Date.fromTime 1433030400000)
    changed = Ui.Calendar.nextDay initial
    expected = Date.fromTime 1433116800000
  in
    suite "nextDay"
      [ test "Should switch selected date"
         (assertEqual (Ext.Date.isSameDate changed.value expected) True)
      , test "Should switch to next month"
        (assertEqual (Ext.Date.isSameDate changed.date expected) True)
      ]

previousDay : Test
previousDay =
  let
    initial = Ui.Calendar.init mailbox.address (Date.fromTime 1430438400000)
    changed = Ui.Calendar.previousDay initial
    expected = Date.fromTime 1430352000000
  in
    suite "previousDay"
      [ test "Should switch to selected date"
         (assertEqual (Ext.Date.isSameDate changed.value expected) True)
      , test "Should switch to previous month"
        (assertEqual (Ext.Date.isSameDate changed.date expected) True)
      ]

updatePreviousMonth : Test
updatePreviousMonth =
  let
    initial = Ui.Calendar.init mailbox.address (Date.fromTime 1430438400000)
    (changed, effect) = Ui.Calendar.update Ui.Calendar.PreviousMonth initial
    expected = Date.fromTime 1427846400000
  in
    test "Should switch to previous month"
      (assertEqual (Ext.Date.isSameDate changed.date expected) True)

updateNextMonth : Test
updateNextMonth =
  let
    initial = Ui.Calendar.init mailbox.address (Date.fromTime 1430438400000)
    (changed, effect) = Ui.Calendar.update Ui.Calendar.NextMonth initial
    expected = Date.fromTime 1433116800000
  in
    test "Should switch to next month"
      (assertEqual (Ext.Date.isSameDate changed.date expected) True)
