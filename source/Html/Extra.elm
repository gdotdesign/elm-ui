module Html.Extra
  ( Dimensions, Position, PositionAndDimension, WindowDimensions, dimensionsDecoder
  , positionDecoder, positionAndDimensionDecoder, windowDimensionsDecoder
  , preventDefaultOptions, stopPropagationOptions, stopOptions, onTransitionEnd
  , onPreventDefault, onEnterPreventDefault, onStop, onStopNothing, onEnter
  , onLoad, onKeys, onInput, onWithDimensions, onScroll, onWithDropdownDimensions
  , DropdownDimensions, onKeysWithDimensions) where

{-| Extra functions / events / decoders for working with HTML.

# Types
@docs Dimensions, Position, PositionAndDimension, WindowDimensions, DropdownDimensions

# Decoders
@docs dimensionsDecoder, positionDecoder, positionAndDimensionDecoder
@docs windowDimensionsDecoder

# Options
@docs preventDefaultOptions, stopPropagationOptions, stopOptions

# Events
@docs onTransitionEnd, onPreventDefault, onEnterPreventDefault, onStop, onScroll
@docs onStopNothing, onEnter, onLoad, onKeys, onInput, onWithDimensions
@docs onWithDropdownDimensions, onKeysWithDimensions
-}
import Html.Events exposing (on, onWithOptions, targetValue, keyCode, defaultOptions)
import Html

import Json.Decode as Json exposing ((:=))
import Dict exposing (Dict)
import Native.Browser
import List

type Nothing = Nothing

-- Mailbox for nothing
nothingMailbox : Signal.Mailbox Nothing
nothingMailbox = Signal.mailbox Nothing

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

{-| Represents the windows dimensions. -}
type alias WindowDimensions =
  { width : Float
  , height : Float
  }

{-| Represents an elemen and its dropdowns dimensions. -}
type alias DropdownDimensions =
  { dimensions : Dimensions
  , dropdown : Dimensions
  , window : WindowDimensions
  }

{-| Decodes the window dimesions. -}
windowDimensionsDecoder : Json.Decoder WindowDimensions
windowDimensionsDecoder =
  Json.at ["target", "ownerDocument", "defaultView"]
    (Json.object2 WindowDimensions
      ("innerWidth" := Json.float)
      ("innerHeight" := Json.float))

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

-- Decoder dimensions from target
atDimensionsDecoder : Json.Decoder Dimensions
atDimensionsDecoder =
  Json.at ["target", "dimensions"] dimensionsDecoder

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

{-| Decodes dimensions for a element and its dropdown. -}
dropdownDimensionsDecoder : Json.Decoder DropdownDimensions
dropdownDimensionsDecoder =
  Json.object3 DropdownDimensions
    atDimensionsDecoder
    (Json.at ["target", "dropdown", "dimensions"] dimensionsDecoder)
    windowDimensionsDecoder

{-| Prevent default options. -}
preventDefaultOptions : Html.Events.Options
preventDefaultOptions =
  { stopPropagation = False
  , preventDefault = True
  }

{-| Stop propagation options. -}
stopPropagationOptions : Html.Events.Options
stopPropagationOptions =
  { stopPropagation = True
  , preventDefault = False
  }

{-| Stop propagation and prevent default options. -}
stopOptions : Html.Events.Options
stopOptions =
  { stopPropagation = True
  , preventDefault = True
  }

{-| Returns dimensions for an element and its dropdown. -}
onWithDropdownDimensions : String -> Signal.Address a ->
                           (DropdownDimensions -> a) -> Html.Attribute
onWithDropdownDimensions event address action =
  onWithOptions
    event
    defaultOptions
    dropdownDimensionsDecoder
    (\dimensions -> Signal.message address (action dimensions))

{-| An event listener that will returns the dimensions of the element that
triggered it and position of the mouse.

    onWithDimensions event preventDefault address action
-}
onWithDimensions : String -> Bool -> Signal.Address a ->
                   (PositionAndDimension -> a) -> Html.Attribute
onWithDimensions event preventDefault address action =
  onWithOptions
    event
    { stopPropagationOptions | preventDefault = preventDefault }
    positionAndDimensionDecoder
    (\dimensions -> Signal.message address (action dimensions))

{-| Transition end event listener. -}
onTransitionEnd : Signal.Address a -> a -> Html.Attribute
onTransitionEnd address action =
  on "transitionend"
     Json.value
     (\_ -> Signal.message address action)

{-| An event listener that will prevent default acitons. -}
onPreventDefault : String -> Signal.Address a -> a -> Html.Attribute
onPreventDefault event address action =
  onWithOptions
    event
    preventDefaultOptions
    Json.value
    (\_ -> Signal.message address action)

{-| An keydown event listener that will prevent default on enter. -}
onEnterPreventDefault : Signal.Address a -> a -> Html.Attribute
onEnterPreventDefault address action =
  onWithOptions
    "keydown"
    preventDefaultOptions
    enterIf
    (\_ -> Signal.message address action)

{-| An event listener that stops propagation and prevents default action. -}
onStop : String -> Signal.Address a -> a -> Html.Attribute
onStop event address handler =
  onWithOptions
    event
    stopOptions
    Json.value
    (\_ -> Signal.message address handler)

{-| An event listener that will stop the event but doesn't require an action. -}
onStopNothing : String -> Html.Attribute
onStopNothing event =
  onWithOptions
    event
    stopOptions
    Json.value
    (\_ -> Signal.message nothingMailbox.address Nothing)

{-| An evnet linstener that runs the given action on enter. -}
onEnter : Bool -> Signal.Address a -> a -> Html.Attribute
onEnter control address handler =
    let
      decoder = if control then controlKey else enterIf
    in
      onWithOptions
        "keydown"
        stopOptions
        decoder
        (\code -> Signal.message address handler)

{-| An event listener that will run the given actions on the associated keys. -}
onKeys : Signal.Address a -> Dict Int a -> Html.Attribute
onKeys address mappings =
  let
    message data =
      case Dict.get data.code mappings of
        Just handler -> Signal.message address handler
        _ -> Signal.message nothingMailbox.address Nothing
  in
    onWithOptions "keydown" preventDefaultOptions (mappingsDecoder mappings) message

{-| An event listener that will run the given actions on the associated keys. -}
onKeysWithDimensions : Signal.Address a -> Dict Int (DropdownDimensions -> a) -> Html.Attribute
onKeysWithDimensions address mappings =
  let
    message data =
      case Dict.get data.code mappings of
        Just handler -> Signal.message address (handler data.dimensions)
        _ -> Signal.message nothingMailbox.address Nothing
  in
    onWithOptions "keydown" preventDefaultOptions (mappingsDecoder mappings) message

{-| An event listener that runs on input. -}
onInput : Signal.Address a -> (String -> a) -> Html.Attribute
onInput address handler =
    on "input" targetValue (\str -> Signal.message address (handler str))

{-| A load event listener .-}
onLoad : Signal.Address a -> a -> Html.Attribute
onLoad address handler =
  on "load" Json.value (\_ -> Signal.message address handler)

{-| A scroll event listner. -}
onScroll : Signal.Address a -> a -> Html.Attribute
onScroll address handler =
  onWithOptions
    "scroll"
    defaultOptions
    Json.value
    (\_ -> Signal.message address handler)

-- A decoder that will only succeed if the ctrlKey is true.
controlKey : Json.Decoder Int
controlKey =
  Json.andThen ("ctrlKey" := Json.bool) controlIf

-- Returns a decoder that will succeed only if the given parameter is true.
controlIf : Bool -> Json.Decoder Int
controlIf ctrl =
  if ctrl then
    enterIf
  else
    Json.fail "Control key isn't pressed!"

-- A decoder that will only succeed on enter
enterIf : Json.Decoder Int
enterIf =
  keyCodeIf 13

-- A decoder that will only succeed if given key is pressed
keyCodeIf : Int -> Json.Decoder Int
keyCodeIf code =
  let
    func code' =
      if code' == code then
        Json.succeed code
      else
        Json.fail "Enter not pressed!"
  in
    Json.andThen keyCode func

type alias KeyWithDimensions =
  { code : Int
  , dimensions: DropdownDimensions
  }

-- A decoder that will run the associated action when the right key is pressed
mappingsDecoder : Dict Int a -> Json.Decoder KeyWithDimensions
mappingsDecoder mappings =
  let
    decodeIf value mappings =
      if List.member value (Dict.keys mappings) then
        Json.succeed value
      else
        Json.fail "Key pressed not in mappings"
  in
    Json.object2 KeyWithDimensions
      (("keyCode" := Json.int) `Json.andThen` (\value -> decodeIf value mappings))
      dropdownDimensionsDecoder
