module Html.Dimensions exposing (..) -- where

import Native.Browser
import Json.Decode as Json exposing ((:=))

import Html.Extra exposing (stopPropagationOptions)
import Html.Events exposing (onWithOptions)
import Html

{-| Represents a HTMLElements dimensions. -}
type alias Dimensions =
  { height: Float
  , width: Float
  , bottom: Float
  , right: Float
  , left: Float
  , top: Float
  }

{-| Represents an events position. -}
type alias Position =
  { pageX: Float
  , pageY: Float
  }

{-| Represents dimensions and position retrieved from an event. -}
type alias PositionAndDimension =
  { dimensions : Dimensions
  , position: Position
  }

{-| Decodes a position and dimesion from an event. -}
positionAndDimensionDecoder : Json.Decoder PositionAndDimension
positionAndDimensionDecoder =
  Json.object2
    PositionAndDimension
    atDimensionsDecoder
    positionDecoder

{-| Decodes a position from an event. -}
positionDecoder : Json.Decoder Position
positionDecoder =
  Json.object2 Position
    ("pageX" := Json.float)
    ("pageY" := Json.float)

{-| Decodes dimensions from an event. -}
dimensionsDecoder : Json.Decoder Dimensions
dimensionsDecoder =
  Json.object6 Dimensions
    ("height" := Json.float)
    ("width" := Json.float)
    ("bottom" := Json.float)
    ("right" := Json.float)
    ("left" := Json.float)
    ("top" := Json.float)

-- Decoder dimensions from target
atDimensionsDecoder : Json.Decoder Dimensions
atDimensionsDecoder =
  boundingClientRectDecoder (Json.at ["target"] Json.value) dimensionsDecoder

boundingClientRectDecoder decoder =
  Native.Browser.boundingClientRectDecoder decoder


{-| An event listener that will returns the dimensions of the element that
triggered it and position of the mouse.

    onWithDimensions event preventDefault address action
-}
onWithDimensions : String -> Bool -> (PositionAndDimension -> msg) -> Html.Attribute msg
onWithDimensions event preventDefault action =
  onWithOptions
    event
    { stopPropagationOptions | preventDefault = preventDefault }
    (Json.map action positionAndDimensionDecoder)
