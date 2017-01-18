module Steps exposing (..)

import Spec.Steps exposing (dispatchEvent)
import Spec.Assertions exposing (Outcome)

import Task exposing (Task)
import Json.Encode as Json

keyDown : Int -> String -> Task Never Outcome
keyDown keyCode selector =
  dispatchEvent
    "keydown"
    (Json.object [("keyCode", Json.int keyCode)])
    selector
