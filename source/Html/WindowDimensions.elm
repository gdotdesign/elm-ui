module Html.WindowDimensions exposing (..)

-- where

import Json.Decode as Json exposing ((:=))

type alias WindowDimensions =
  { width : Float
  , height : Float
  }

decoder : Json.Decoder WindowDimensions
decoder =
  Json.at ["target", "ownerDocument", "defaultView"]
    (Json.object2 WindowDimensions
      ("innerWidth" := Json.float)
      ("innerHeight" := Json.float))
