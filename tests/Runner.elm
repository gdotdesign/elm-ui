module Main where

import String
import Task
import Console
import ElmTest exposing (..)

import Ui.AppTests
import Ui.CheckboxTests

tests : Test
tests =
  suite "A Test Suite"
    [ Ui.AppTests.tests
    , Ui.CheckboxTests.tests
    ]

port runner : Signal (Task.Task x ())
port runner =
  Console.run (consoleRunner tests)
