module Ext.Number where

{-| Utility functions for numbers.

@docs toFixed, remFloat, roundTo
-}

import Native.Browser

{-| Rounds the given number to the given precision. -}
toFixed : Int -> Float -> String
toFixed precision number =
  Native.Browser.toFixed number precision

{-| Remainder function that works on floats. -}
remFloat : Float -> Float -> Float
remFloat a b =
  Native.Browser.rem a b

{-| Rounds the given number to the given precision. -}
roundTo : Int -> Float -> Float
roundTo precision number =
  let
    magnitude = 10 * precision
  in
    (toFloat (round (number * magnitude))) / magnitude
