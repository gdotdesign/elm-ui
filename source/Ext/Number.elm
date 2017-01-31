module Ext.Number exposing (..)

{-| This module provides utility functions for numbers.

# Functions
@docs toFixed, remFloat, roundTo
-}

import Native.Number

{-| Formats a number using fixed-point notation. It's the direct wrapper for
JavaScripts [toFixed](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toFixed).

    Ext.Number.toFixed 0.12340 2 -- "0.12"
    Ext.Number.toFxied 12 2 -- "12.00"
-}
toFixed : Int -> Float -> String
toFixed precision number =
  Native.Number.toFixed number precision


{-| Remainder function that works on floats.

    0.1 `Ext.Number.rem` 0.2 -- 0.1
-}
remFloat : Float -> Float -> Float
remFloat a b =
  Native.Number.rem a b


{-| Rounds the given number to the given precision.

    Ext.Number.roundTo 2 0.123 -- 0.123
-}
roundTo : Int -> Float -> Float
roundTo precision number =
  let
    magnitude =
      10 * precision
      |> toFloat
  in
    (toFloat (round (number * magnitude))) / magnitude
