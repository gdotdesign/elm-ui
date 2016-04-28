module Html.Extra exposing (..)

-- where

import Html.Events exposing (on, keyCode, onWithOptions)
import Html.Dimensions exposing (..)
import Json.Decode as Json exposing ((:=))
import Html
import Dict


{-| Prevent default options.
-}
preventDefaultOptions : Html.Events.Options
preventDefaultOptions =
  { stopPropagation = False
  , preventDefault = True
  }


{-| Stop propagation options.
-}
stopPropagationOptions : Html.Events.Options
stopPropagationOptions =
  { stopPropagation = True
  , preventDefault = False
  }


{-| Options for completely stopping an event and
preventing it's default behavior.
-}
stopOptions : Html.Events.Options
stopOptions =
  { stopPropagation = True
  , preventDefault = True
  }


{-| An keydown event listener that will prevent default on enter.
-}
onEnterPreventDefault : msg -> Html.Attribute msg
onEnterPreventDefault action =
  let
    mappings =
      [ ( 13, action ) ]
  in
    onWithOptions "keydown" preventDefaultOptions (keysDecoder mappings)


{-| An event listener that stops propagation and prevents default action.
-}
onStop : String -> msg -> Html.Attribute msg
onStop event msg =
  onWithOptions event stopOptions (Json.succeed msg)


{-| Capture [scroll](https://developer.mozilla.org/en-US/docs/Web/Events/scroll)
events.
-}
onScroll : msg -> Html.Attribute msg
onScroll msg =
  on "scroll" (Json.succeed msg)


{-| Transition end event listener. -}
onTransitionEnd : msg -> Html.Attribute msg
onTransitionEnd msg =
  on "transitionend" (Json.succeed msg)


{-| Capture [keydown](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)
events that will call the given action when a specific key
is pressed from the give list

  onKeys [ (13, Enter)
         , (27, Esc)
         ]
-}
onKeys : List ( Int, msg ) -> Html.Attribute msg
onKeys mappings =
  onWithOptions "keydown" stopOptions (keysDecoder mappings)


{-| Capture [load](https://developer.mozilla.org/en-US/docs/Web/Events/load)
events for things like script, link or image tags.
-}
onLoad : msg -> Html.Attribute msg
onLoad msg =
  on "load" (Json.succeed msg)


{-| Capture [mousemove](https://developer.mozilla.org/en-US/docs/Web/Events/mousemove)
events.
-}
onMouseMove : (( Int, Int ) -> msg) -> Html.Attribute msg
onMouseMove msg =
  on "mousemove" (Json.map msg pagePositionDecoder)


{-| Decoders pageX and pageY fields of an event into a tuple.
-}
pagePositionDecoder : Json.Decoder ( Int, Int )
pagePositionDecoder =
  Json.object2
    (,)
    ("pageX" := Json.int)
    ("pageY" := Json.int)


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


{-| A decoder which succeeds when a specific key
is pressed from the given list.

  on "keydown" [(13, Enter)]
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
    Json.andThen keyCode decode
