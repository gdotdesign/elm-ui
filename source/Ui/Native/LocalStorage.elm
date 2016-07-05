module Ui.Native.LocalStorage exposing (..)

{-| Native bindings for the `localStorage` interface using tasks.

# Functions
@docs getItem, setItem, removeItem
-}

import Task exposing (Task)
import Native.LocalStorage


{-| Gets the value of the item from the given key.

    task = Ui.Native.LocalStorage.getItem "key"
-}
getItem : String -> Task String String
getItem key =
  Native.LocalStorage.get key


{-| Sets the value of the item from given key to the given value.

    task = Ui.Native.LocalStorage.setItem "key" "value"
-}
setItem : String -> String -> Task String String
setItem key value =
  Native.LocalStorage.set key value


{-| Removes the item with the given key.

    task = Ui.Native.LocalStorage.remove "key"
-}
removeItem : String -> Task String String
removeItem key =
  Native.LocalStorage.remove key
