module Steps exposing (..)

import Spec exposing (steps, Outcome)
import Task exposing (Task)
import Json.Encode as Json

clickSvg : String -> Task Never Outcome
clickSvg selector =
  steps.dispatchEvent
    "click"
    (Json.object [])
    selector


keyDown : Int -> String -> Task Never Outcome
keyDown keyCode selector =
  steps.dispatchEvent
    "keydown"
    (Json.object [("keyCode", Json.int keyCode)])
    selector


mouseMove : Int -> Int -> Task Never Outcome
mouseMove top left =
  steps.dispatchEvent "mousemove"
  (Json.object
    [ ( "pageX", Json.int left )
    , ( "pageY", Json.int top )
    ]
  )
  "document"


mouseDown : Int -> Int -> String -> Task Never Outcome
mouseDown left top selector =
  steps.dispatchEvent "mousedown"
  (Json.object
    [ ( "pageX", Json.int left )
    , ( "pageY", Json.int top )
    ]
  )
  selector


mouseUp : Task Never Outcome
mouseUp =
  steps.dispatchEvent
    "mouseup"
    (Json.object
      [ ( "pageX", Json.int 0 )
      , ( "pageY", Json.int 0 )
      ])
    "document"
