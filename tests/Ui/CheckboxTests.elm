module Ui.CheckboxTests where

import ElmTest exposing (..)

import Ui.Checkbox

tests : Test
tests =
  suite "Ui.Checkbox" [updateValue]

mailbox : Signal.Mailbox Bool
mailbox =
  Signal.mailbox False

updateValue : Test
updateValue =
  let
    initial = Ui.Checkbox.init False mailbox.address
    (changed, effect) = Ui.Checkbox.update Ui.Checkbox.Toggle initial
  in
    test "Toggle should toggle value"
      (assertEqual changed.value True)
