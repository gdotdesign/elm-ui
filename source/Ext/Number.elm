module Ext.Number where

{-| Utility functions for numbers.

@docs formatFloat, remFloat, roundTo
-}

import Native.Browser

{-| Rounds the given number to the given precision. -}
formatFloat : Int -> Float -> String
formatFloat precision number =
  Native.Browser.toFixed number precision

{-| Runs native modulo. -}
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
