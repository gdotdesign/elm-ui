module Ext.Number where

{-| Utility functions for numbers.

@docs formatFloat
-}

import Native.Browser

{-| Rounds the given number to the given precision --}
formatFloat : Int -> Float -> String
formatFloat precision number =
  Native.Browser.toFixed number precision
