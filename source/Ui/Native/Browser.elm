module Ui.Native.Browser exposing (..)

import Task exposing (Task)
import Native.Browser

--where

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
