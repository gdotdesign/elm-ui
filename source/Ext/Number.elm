module Ext.Number where

{-| Utility functions for numbers.

@docs formatFloat, remFloat
-}

import Native.Browser

{-| Rounds the given number to the given precision --}
formatFloat : Int -> Float -> String
formatFloat precision number =
  Native.Browser.toFixed number precision

{-| Runs native modulo. -}
remFloat : Float -> Float -> Float
remFloat a b =
  Native.Browser.rem a b
