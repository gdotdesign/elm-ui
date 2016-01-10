module Ui.CheckboxTests where

import ElmTest exposing (..)

import Ui.Checkbox

tests : Test
tests =
  suite "Ui.Checkbox" [updateValue]

updateValue : Test
updateValue =
  let
    initial = Ui.Checkbox.init False
    (changed, effect) = Ui.Checkbox.update Ui.Checkbox.Toggle initial
  in
    test "Toggle should toggle value"
      (assertEqual changed.value True)
