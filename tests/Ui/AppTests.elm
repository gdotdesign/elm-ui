module Ui.AppTests where

import ElmTest exposing (..)

import Ui.App

tests : Test
tests =
  suite "Ui.App" [updateLoaded]

mailbox : Signal.Mailbox Bool
mailbox =
  Signal.mailbox False

updateLoaded : Test
updateLoaded =
  let
    initial = Ui.App.init mailbox.address mailbox.address "Test"
    (changed, effect) = Ui.App.update Ui.App.Loaded initial
  in
    test "Loaded should set loaded value"
      (assertEqual changed.loaded True)
