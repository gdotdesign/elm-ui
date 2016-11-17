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

import Html.Events.Options exposing (stopPropagationOptions)
import Html.Events exposing (onWithOptions)
import Html

import Json.Decode as Json exposing (field)

import Ui.Native.Dom as Dom


{-| Represents a HTMLElements dimensions, specifically the ClientRect object
returned by [getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect)
function with scroll position additions.
-}
type alias ElementDimensions =
  { scrollLeft : Float
  , scrollTop : Float
  , height : Float
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
  Json.map2
    MousePosition
    (field "pageX" Json.float)
    (field "pageY" Json.float)


{-| Decodes dimensions from an HTMLElement.
-}
decodeElementDimensions : Json.Decoder ElementDimensions
decodeElementDimensions =
  Dom.withBoundingClientRect
    (Json.map8
      ElementDimensions
      (field "scrollLeft" Json.float)
      (field "scrollTop" Json.float)
      (field "height" Json.float)
      (field "width" Json.float)
      (field "bottom" Json.float)
      (field "right" Json.float)
      (field "left" Json.float)
      (field "top" Json.float)
    )


{-| Decodes the windows size form an event.
-}
decodeWindowSize : Json.Decoder WindowSize
decodeWindowSize =
  let
    decoder =
      Json.map2
        WindowSize
        (field "innerHeight" Json.float)
        (field "innerWidth" Json.float)
  in
    Json.at [ "target", "ownerDocument", "defaultView" ] decoder


{-| An event listener that will returns the dimensions of the element that
triggered it, position of the mouse and window size.
-}
onWithDimensions : String -> Bool -> (Dimensions -> msg) -> Html.Attribute msg
onWithDimensions event preventDefault action =
  let
    decoder =
      Json.map3
        (,,)
        decodeMousePosition
        (Json.at [ "target" ] decodeElementDimensions)
        decodeWindowSize
  in
    onWithOptions
      event
      { stopPropagationOptions | preventDefault = preventDefault }
      (Json.map action decoder)
