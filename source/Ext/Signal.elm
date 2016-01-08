module Ext.Signal where

{-| Utility functions for working with signals.

@docs sendAsEffect
-}
import Effects
import Signal

{-| Sends the given value to the given address and turns it into an effect
for a different address.

    Signal.sendAsEffect address value action
-}
sendAsEffect : Signal.Address a -> a -> (() -> b) -> Effects.Effects b
sendAsEffect address value action =
  Signal.send address value
    |> Effects.task
    |> Effects.map action
