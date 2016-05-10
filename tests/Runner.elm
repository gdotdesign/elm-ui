module Main exposing (..)

import String
import Task
import ElmTest exposing (..)

import Ext.DateTests

tests : Test
tests =
  suite "A Test Suite"
    [ Ext.DateTests.tests
    ]

main =
  runSuite tests
