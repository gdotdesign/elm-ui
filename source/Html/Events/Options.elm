module Html.Events.Options exposing (..)

{-| Extra options for event handlers.

# Options
@docs preventDefaultOptions, stopPropagationOptions, stopOptions
-}

import Html.Events exposing (Options)

{-| Prevent default options.
-}
preventDefaultOptions : Options
preventDefaultOptions =
  { stopPropagation = False
  , preventDefault = True
  }


{-| Stop propagation options.
-}
stopPropagationOptions : Options
stopPropagationOptions =
  { stopPropagation = True
  , preventDefault = False
  }


{-| Options for completely stopping an event and
preventing it's default behavior.
-}
stopOptions : Options
stopOptions =
  { stopPropagation = True
  , preventDefault = True
  }
