module Storage.Local where

import Native.LocalStorage

getItem : String -> Result String String
getItem key =
  Native.LocalStorage.get key

setItem : String -> String -> Result String String
setItem key value =
  Native.LocalStorage.set key value

removeItem : String -> Result String String
removeItem key =
  Native.LocalStorage.remove key
