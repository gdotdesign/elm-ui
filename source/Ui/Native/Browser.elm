module Ui.Native.Browser exposing
  ( Location, location, openWindow, redirect, alert, setTitle )

{-| This module provides browser related utility functions.

# Window
@docs openWindow, redirect, alert, setTitle


# Location
@docs Location, location
-}

import Json.Decode as Json exposing (field)
import Task exposing (Task)
import String

import Native.Browser


{-| Location model.
-}
type alias Location =
  { pathname : String
  , hostname : String
  , protocol : String
  , search : String
  , host : String
  , hash : String
  , port_ : Int
  }


{-| The current location object.
-}
location : () -> Location
location _ =
  Json.decodeValue decodeLocation (Native.Browser.location ())
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
  , port_ = 0
  }


{-| Decodes a location object.
-}
decodeLocation : Json.Decoder Location
decodeLocation =
  let
    convertPort port_ =
      String.toInt port_
        |> Result.withDefault 0
        |> Json.succeed
  in
    Json.map7
      Location
      (field "pathname" Json.string)
      (field "hostname" Json.string)
      (field "protocol" Json.string)
      (field "search" Json.string)
      (field "host" Json.string)
      (field "hash" Json.string)
      (field "port" Json.string |> Json.andThen convertPort)


{-| Returns a task for opening a new window with the given url, if the window is
blocked by a popup blocker it will fail.

    task = Ui.Native.Browser.openWindow "url"
-}
openWindow : String -> Task String ()
openWindow url =
  Native.Browser.openWindow url


{-| Returns a task for replacing the current page with the given URL.

    task = Ui.Native.Browser.redirect "http://elm-lang.org"
-}
redirect : String -> Task Never ()
redirect url =
  Native.Browser.redirect url


{-| Returns a task for showing an alert dialog with the given text.

    task = Ui.Native.Browser.alert "Hey there!"
-}
alert : String -> Task Never ()
alert message =
  Native.Browser.alert message


{-| Sets the title of the document.

    task = Ui.Browser.setTitle "New Title"
-}
setTitle : String -> Task Never ()
setTitle title =
  Native.Browser.setTitle title
