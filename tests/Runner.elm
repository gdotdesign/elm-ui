module Main where

import String
import Task
import Console
import ElmTest exposing (..)

import Ui.AppTests

tests : Test
tests =
  suite "A Test Suite"
    [ Ui.AppTests.tests
    , test "Addition" (assertEqual (3 + 7) 10)
    , test "String.left" (assertEqual "a" (String.left 1 "abcdefg"))
    , test "This test should fail" (assert False)
    ]

port runner : Signal (Task.Task x ())
port runner =
  Console.run (consoleRunner tests)
