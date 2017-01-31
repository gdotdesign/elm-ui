module Html.Events.Extra exposing (..)

{-| Event handlers and event decoders that are not part of _elm-lang/html_.

# Generic
@docs onPreventDefault

# Keyboard Related
@docs onEnter, onEnterPreventDefault, onKeys, keysDecoder

# Miscellaneous
@docs onScroll, onTransitionEnd, onLoad, onError, onWheel, decodeDelta
@docs unobtrusiveClick, onFocusOut
-}

import Html.Events.Options exposing (preventDefaultOptions, stopOptions)
import Html.Events exposing (on, keyCode, onWithOptions, defaultOptions)
import Html

import Json.Decode as Json exposing (field)

import Dict

{-| Creates an attribute for the **click** event that will stop the event if
the control key or the middle mouse button is not pressed.

It works this way to not to hinder the browsers basic ability to open
the link in new pages.
-}
unobtrusiveClick : msg -> Html.Attribute msg
unobtrusiveClick msg =
  let
    result ( ctrlKey, button ) =
      if ctrlKey || button == 1 then
        Json.fail "Control key or middle mouse button is pressed!"
      else
        Json.succeed msg

    decoder =
      Json.map2 (,)
        (field "ctrlKey" Json.bool)
        (field "button" Json.int)
        |> Json.andThen result
  in
    onWithOptions "click" stopOptions decoder


{-| Decodes delta value from wheel events.
-}
decodeDelta : Json.Decoder Float
decodeDelta =
  Json.at [ "deltaY" ] Json.float


{-| Capture [wheel](https://developer.mozilla.org/en-US/docs/Web/Events/wheel)
events.
-}
onWheel : Json.Decoder data -> (data -> msg) -> Html.Attribute msg
onWheel decoder action =
  on "wheel" (Json.map action decoder)


{-| Capture [focusout](https://developer.mozilla.org/en-US/docs/Web/Events/focusout)
events.
-}
onFocusOut : msg -> Html.Attribute msg
onFocusOut msg =
  on "focusout" (Json.succeed msg)


{-| Capture [keyup](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)
events that have the enter key pressed, additionally if the first agrument is
true it will fail if the control key is not pressed.

    Html.Events.Extra.onEnter False Send -- calls Send on enter
    Html.Events.Extra.onEnter True Send -- calls Send on ctrl+enter
-}
onEnter : Bool -> msg -> Html.Attribute msg
onEnter control msg =
  let
    decoder2 pressed =
      if pressed then
        keysDecoder [ ( 13, msg ) ]
      else
        Json.fail "Control wasn't pressed!"

    decoder =
      if control then
        Json.andThen
          decoder2
          (field "ctrlKey" Json.bool)
      else
        (decoder2 True)
  in
    onWithOptions
      "keyup"
      stopOptions
      decoder


{-| Capture [keydown](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)
events that have the enter key pressed and prevent their default behavior.

    Html.Events.Extra.onEnterPreventDefault Send
    -- prevents default and calls Send on enter
-}
onEnterPreventDefault : msg -> Html.Attribute msg
onEnterPreventDefault action =
  let
    mappings =
      [ ( 13, action ) ]
  in
    onWithOptions "keydown" preventDefaultOptions (keysDecoder mappings)


{-| Capture events and prevent their default behavior.

    Html.Events.Extra.onPreventDefault "keyup" Update
-}
onPreventDefault : String -> msg -> Html.Attribute msg
onPreventDefault event msg =
  onWithOptions
    event
    preventDefaultOptions
    (Json.succeed msg)


{-| Capture [scroll](https://developer.mozilla.org/en-US/docs/Web/Events/scroll)
events.
-}
onScroll : msg -> Html.Attribute msg
onScroll msg =
  on "scroll" (Json.succeed msg)


{-| Capture [transitionend](https://developer.mozilla.org/en-US/docs/Web/Events/transitionend)
events.
-}
onTransitionEnd : Json.Decoder msg -> Html.Attribute msg
onTransitionEnd decoder =
  on "transitionend" decoder


{-| Capture [keydown](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)
events that will call the given action when a specific key
is pressed from the give list.

    onKeys [ ( 13, Enter )
           , ( 27, Esc )
           ]
-}
onKeys : Bool -> List ( Int, msg ) -> Html.Attribute msg
onKeys shouldPreventDefault mappings =
  let
    options =
      if shouldPreventDefault then
        preventDefaultOptions
      else
        defaultOptions
  in
    onWithOptions "keydown" options (keysDecoder mappings)


{-| Capture [load](https://developer.mozilla.org/en-US/docs/Web/Events/load)
events for things like script, link or image tags.
-}
onLoad : msg -> Html.Attribute msg
onLoad msg =
  on "load" (Json.succeed msg)


{-| Capture [error](https://developer.mozilla.org/en-US/docs/Web/Events/error)
events for things like script, link or image tags.
-}
onError : msg -> Html.Attribute msg
onError msg =
  on "error" (Json.succeed msg)


{-| A decoder which succeeds when a specific key is pressed from the given list.

    Html.Events.on "keydown" (Html.Events.Extra.keysDecoder [ ( 13, Enter ) ])
-}
keysDecoder : List ( Int, msg ) -> Json.Decoder msg
keysDecoder mappings =
  let
    dict =
      Dict.fromList mappings

    decode value =
      Dict.get value dict
        |> Maybe.map Json.succeed
        |> Maybe.withDefault (Json.fail "Key pressed not was no in mappings!")
  in
    Json.andThen decode keyCode
