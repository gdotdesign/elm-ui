module Html.Events.Geometry exposing (..)

{-| Helper models, decoders and event handlers for extracting HTMLElement
dimensions, mouse position and window size from events.

# Models
@docs ElementDimensions, MousePosition, WindowSize, Dimensions

# Decoders
@docs decodeElementDimensions, decodeMousePosition, decodeWindowSize

# EventHandlers
@docs onWithDimensions
-}

-- where

import Html.Events.Options exposing (stopPropagationOptions)
import Html.Events exposing (onWithOptions)
import Html

import Json.Decode as Json exposing ((:=))

import Ui.Native.Dom as Dom


{-| Represents a HTMLElements dimensions, specifically the ClientRect object
returned by [getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect)
function.
-}
type alias ElementDimensions =
  { height : Float
  , width : Float
  , bottom : Float
  , right : Float
  , left : Float
  , top : Float
  }


{-| Represents the position of the mouse.
-}
type alias MousePosition =
  { left : Float
  , top : Float
  }


{-| Represents the size of the window.
-}
type alias WindowSize =
  { height : Float
  , width : Float
  }


{-| Dimensions to generally use that contain MousePosition, ElementDimensions
and WindowSize.
-}
type alias Dimensions =
  ( MousePosition, ElementDimensions, WindowSize )


{-| Decodes the mouse position from an event.
-}
decodeMousePosition : Json.Decoder MousePosition
decodeMousePosition =
  Json.object2
    MousePosition
    ("pageX" := Json.float)
    ("pageY" := Json.float)


{-| Decodes dimensions from an HTMLElement.
-}
decodeElementDimensions : Json.Decoder ElementDimensions
decodeElementDimensions =
  Dom.withBoundingClientRect
    (Json.object6
      ElementDimensions
      ("height" := Json.float)
      ("width" := Json.float)
      ("bottom" := Json.float)
      ("right" := Json.float)
      ("left" := Json.float)
      ("top" := Json.float)
    )


{-| Decodes the windows size form an event.
-}
decodeWindowSize : Json.Decoder WindowSize
decodeWindowSize =
  let
    decoder =
      Json.object2
        WindowSize
        ("innerHeight" := Json.float)
        ("innerWidth" := Json.float)
  in
    Json.at [ "target", "ownerDocument", "defaultView" ] decoder


{-| An event listener that will returns the dimensions of the element that
triggered it, position of the mouse and window size.
-}
onWithDimensions : String -> Bool -> (Dimensions -> msg) -> Html.Attribute msg
onWithDimensions event preventDefault action =
  let
    decoder =
      Json.object3
        (,,)
        decodeMousePosition
        (Json.at [ "target" ] decodeElementDimensions)
        decodeWindowSize
  in
    onWithOptions
      event
      { stopPropagationOptions | preventDefault = preventDefault }
      (Json.map action decoder)
