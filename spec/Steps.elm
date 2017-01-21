module Steps exposing (..)

import Spec exposing (steps, Outcome)
import Task exposing (Task)
import Json.Encode as Json

keyDown : Int -> String -> Task Never Outcome
keyDown keyCode selector =
  steps.dispatchEvent
    "keydown"
    (Json.object [("keyCode", Json.int keyCode)])
    selector
