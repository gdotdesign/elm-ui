module Main where

import String
import Task
import Console
import ElmTest exposing (..)

import Ui.AppTests
import Ui.CheckboxTests
import Ui.CalendarTests

tests : Test
tests =
  suite "A Test Suite"
    [ Ui.AppTests.tests
    , Ui.CheckboxTests.tests
    , Ui.CalendarTests.tests
    ]

port runner : Signal (Task.Task x ())
port runner =
  Console.run (consoleRunner tests)
