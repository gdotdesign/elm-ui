module Ui.Native.Uid exposing (..)

{-| Natively generate unique hash ids.

# Functions
@docs uid
-}

import Native.Uid

{-| Generates a unique id from an empty tuple.
-}
uid : () -> String
uid =
  Native.Uid.uid
