module Storage.Local where

{-| Native bindings for the localStorage interface using results.

# Functions
@docs getItem, setItem, removeItem
-}
import Native.LocalStorage

{-| Gets the value of the item from the given key. -}
getItem : String -> Result String String
getItem key =
  Native.LocalStorage.get key

{-| Sets the value of the item from given key to the given value. -}
setItem : String -> String -> Result String String
setItem key value =
  Native.LocalStorage.set key value

{-| Removes the item with the given key. -}
removeItem : String -> Result String String
removeItem key =
  Native.LocalStorage.remove key
