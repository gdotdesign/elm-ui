module Ui.Native.Dom exposing (..)

import Json.Decode as Json
import Task exposing (Task)
import Native.Dom

-- where

{-| Focuses a DOM element with the given selector.

    Ui.Native.Browser.focusSelector 'input#comments'
-}
focusSelector : String -> Task Never Never
focusSelector selector =
  Native.Dom.focusSelector selector


{-| Focuses a DOM element with the given uid attribute.

    Ui.Native.Browser.focusUid 'xxxx-xxx-xxx-xxxx'
-}
focusUid : String -> Task Never Never
focusUid uid =
  focusSelector ("[uid='" ++ uid ++ "']")


elementFunctionDecoder : String -> String -> Json.Decoder a -> Json.Decoder a
elementFunctionDecoder function value decoder =
  Native.Dom.elementFunctionDecoder function value decoder

withBoundingClientRect : Json.Decoder a -> Json.Decoder a
withBoundingClientRect decoder =
  elementFunctionDecoder "getBoundingClientRect" "" decoder

withClosest : String -> Json.Decoder a -> Json.Decoder a
withClosest selector decoder =
  elementFunctionDecoder "closest" selector decoder

withSelector : String -> Json.Decoder a -> Json.Decoder a
withSelector selector decoder =
  elementFunctionDecoder "querySelector" selector decoder
