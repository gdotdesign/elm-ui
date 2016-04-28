module Vendor exposing (Prefix(Moz, Webkit, MS, O, Unknown), prefix)

{-| A tiny module that detects the browser vendor prefix

```elm
displayValue : String
displayValue =
    if Vendor.prefix == Vendor.Webkit
    then "-webkit-flex"
    else "flex"
```

@docs Prefix, prefix
-}

import Native.Vendor

{-| A union of prefix tags
-}
type Prefix = Moz | Webkit | MS | O | Unknown


{-| The detected vendor
-}
prefix : Prefix
prefix =
    if Native.Vendor.prefix == "webkit" then Webkit
    else if Native.Vendor.prefix == "moz" then Moz
    else if Native.Vendor.prefix == "ms" then MS
    else if Native.Vendor.prefix == "o" then O
    else Unknown
