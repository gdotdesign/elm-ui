module Ui.Native.Browser exposing
  (Location, location, Prefix(..), prefix, openWindow, redirect, alert)

{-| Browser related helper functions.

# Window
@docs openWindow, redirect, alert

# Vendor Prefix
@docs Prefix, prefix

# Location
@docs Location, location
-}

import Json.Decode as Json exposing ((:=))
import Task exposing (Task)
import String

import Native.Browser


{-| A union of prefix tags.
-}
type Prefix
  = Moz
  | Webkit
  | MS
  | O
  | Unknown


{-| Location model.
-}
type alias Location =
  { pathname : String
  , hostname : String
  , protocol : String
  , search : String
  , host : String
  , hash : String
  , port' : Int
  }


{-| The current location object.
-}
location : Location
location =
  Json.decodeValue decodeLocation Native.Browser.location
    |> Result.withDefault emptyLocation


{-| Empty location model.
-}
emptyLocation : Location
emptyLocation =
  { pathname = ""
  , hostname = ""
  , protocol = ""
  , search = ""
  , host = ""
  , hash = ""
  , port' = 0
  }


{-| Decodes a location object.
-}
decodeLocation : Json.Decoder Location
decodeLocation =
  let
    convertPort port' =
      String.toInt port'
        |> Result.withDefault 0
        |> Json.succeed
  in
    Json.object7
      Location
      ("pathname" := Json.string)
      ("hostname" := Json.string)
      ("protocol" := Json.string)
      ("search" := Json.string)
      ("host" := Json.string)
      ("hash" := Json.string)
      ("port" := Json.string `Json.andThen` convertPort)


{-| Opens a new window with the given URL and return the given value.

    Ui.Native.Browser.openWindow 'asd' value
-}
openWindow : String -> value -> value
openWindow url value =
  Native.Browser.openWindow url value


{-| Replace the current page with the given URL and return the given value.

    Ui.Native.Browser.redirect 'http://elm-lang.org' value
-}
redirect : String -> value -> value
redirect url value =
  Native.Browser.redirect url value


{-| Shows an alert dialog with the given text and returns the given value.

    Ui.Native.Browser.alert 'Hey there!' value
-}
alert : String -> value -> value
alert message value =
  Native.Browser.alert message value


{-| The detected vendor prefix.

    ```elm
    displayValue : String
    displayValue =
        if Vendor.prefix == Vendor.Webkit
        then "-webkit-flex"
        else "flex"
    ```
-}
prefix : Prefix
prefix =
  if Native.Browser.prefix == "webkit" then
    Webkit
  else if Native.Browser.prefix == "moz" then
    Moz
  else if Native.Browser.prefix == "ms" then
    MS
  else if Native.Browser.prefix == "o" then
    O
  else
    Unknown
