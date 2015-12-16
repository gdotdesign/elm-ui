module Html.Extra where

import Native.Browser
import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, targetValue, keyCode)
import Json.Decode as Json exposing ((:=))
import Dict
import List

import Debug exposing (log)

type alias Dimensions =
  { height: Float
  , width: Float
  , left: Float
  , top: Float }

type alias Position =
  { pageX: Float
  , pageY: Float }

type alias DnD =
  { position: Position, dimensions : Dimensions }

type alias KeyDnD =
  { code : Int, dimensions : Dimensions }

dimensionDecoder =
  Json.object2 DnD (Json.object2 Position ("pageX" := Json.float) ("pageY" := Json.float))
    dimDecoder

dimDecoder =
    (Json.at ["target", "dimensions"] (Json.object4 Dimensions
      ("height" := Json.float)
      ("width" := Json.float)
      ("left" := Json.float)
      ("top" := Json.float)))

keyCodeAndDimesnionsDecoder mappings =
  Json.object2 KeyDnD (decoder mappings) dimDecoder

onWithDimensions event preventDefault address action =
  onWithOptions event
                { stopPropagation = True, preventDefault = preventDefault }
                dimensionDecoder
                (\dimensions -> Signal.message address (action dimensions))

onKeysWithDimension address nothingHandler mappings =
  let
    message {code, dimensions} =
      case Dict.get code mappings of
        Just handler -> Signal.message address (handler dimensions)
        _ -> Signal.message address nothingHandler
  in
    onWithOptions "keydown" preventDefaultOptions (keyCodeAndDimesnionsDecoder mappings) message

controlKey =
  Json.andThen ("ctrlKey" := Json.bool) controlIf

controlIf : Bool -> Json.Decoder (Int)
controlIf ctrl =
  if ctrl then
    enterIf
  else
    Json.fail "Control key isn't pressed!"

enterIf =
  keyCodeIf 13

downIf =
  keyCodeIf 40

keyCodeIf code =
  let
    func code' =
      if code' == code then
        Json.succeed code
      else
        Json.fail "Enter not pressed!"
  in
    Json.andThen keyCode func

preventDefaultOptions =
  { stopPropagation = False
  , preventDefault = True }

stopPropagationOptions =
  { stopPropagation = True
  , preventDefault = False }

onTransitionEnd address action =
  on "transitionend"
     Json.value
     (\_ -> Signal.message address action)

onPreventDefault event address action =
  onWithOptions event
                preventDefaultOptions
                Json.value
                (\_ -> Signal.message address action)

onClickOffsetX address action =
  onWithOptions "click"
                stopPropagationOptions
                ("offsetX" := Json.int)
                (\left -> Signal.message address (action left))

onClickStop address action =
  onWithOptions "click"
                stopPropagationOptions
                Json.value
                (\_ -> Signal.message address action)

onEnterStop address action =
  onWithOptions "keydown"
                preventDefaultOptions
                enterIf
                (\_ -> Signal.message address action)

onStop event address handler =
  let
    options =
      { stopPropagation = True
      , preventDefault = True }
  in
    onWithOptions event options (Json.succeed 0) (\_ -> Signal.message address handler)

type Nothing = Nothing

onStopNothing event =
  let
    mailbox = Signal.mailbox Nothing
    options =
      { stopPropagation = True
      , preventDefault = True }
  in
    onWithOptions event options (Json.succeed 0) (\_ -> Signal.message mailbox.address Nothing)

onNoDefault event address handler =
  onWithOptions event preventDefaultOptions (Json.succeed 0) (\_ -> Signal.message address handler)

onEnter : Bool -> Signal.Address a -> a -> Attribute
onEnter control address handler =
    let
      decoder = if control then controlKey else enterIf
      options =
        { stopPropagation = True
        , preventDefault = True }
    in
      onWithOptions "keydown" options decoder (\code -> Signal.message address handler)

decodeIf value mappings =
  if List.member value (Dict.keys mappings) then
    Json.succeed value
  else
    Json.fail "Key pressed not in mappings"

decoder mappings=
  ("keyCode" := Json.int) `Json.andThen` (\value -> decodeIf value mappings)

onKeys address nothingHandler mappings =
  let
    message code =
      case Dict.get code mappings of
        Just handler -> Signal.message address handler
        _ -> Signal.message address nothingHandler
  in
    onWithOptions "keydown" preventDefaultOptions (decoder mappings) message

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address handler =
    on "input" targetValue (\str -> Signal.message address (handler str))

onTouch address handler =
  on "touchend" Json.value (\_ -> Signal.message address handler)

onLoad address handler =
  on "load" Json.value (\_ -> Signal.message address handler)
