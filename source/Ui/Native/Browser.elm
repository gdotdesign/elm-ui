module Ui.Native.Browser exposing (..)

{-| Browser related helper functions.

@docs openWindow, redirect, alert

# Vendor Prefix
@docs Prefix, prefix
-}

import Task exposing (Task)

import Native.Browser


{-| A union of prefix tags.
-}
type Prefix
  = Moz
  | Webkit
  | MS
  | O
  | Unknown


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
