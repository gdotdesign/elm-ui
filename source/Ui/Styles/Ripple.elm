module Ui.Styles.Ripple exposing (style)

{-| Styles for the ripple effect.

@docs style
-}
import Ui.Css.Properties exposing (..)

import Html.Styles exposing (Style, selector, pseudo)

{-| Returns the style node for the ripple effect.
-}
style : { base: List (String, String), selectors: List Style }
style =
  { base =
    [ position relative
    , overflow hidden
    ]
  , selectors =
    [ pseudo ":focus svg[ripple]"
      [ transition
        [ { easing = "cubic-bezier(0.215, 0.61, 0.355, 1)"
          , duration = ms 320
          , property = "all"
          , delay = ms 0
          }
        ]
      , transform [ (scale 1.5) ]
      , opacity 0.3
      ]

    , pseudo ":active svg[ripple]"
      [ opacity 0.6
      ]

    , pseudo ":before"
      [ position relative
      , zIndex 2
      ]

    , pseudo ":after"
      [ position relative
      , zIndex 2
      ]

    , selector "> *"
      [ position relative
      , zIndex 2
      ]

    , selector "svg[ripple]"
      [ transition
        [ { property = "opacity"
          , duration = ms 200
          , easing = "ease"
          , delay = ms 0
          }
        , { property = "transform"
          , duration = ms 1
          , easing = "ease"
          , delay = ms 200
          }
        ]
      , transformOrigin zero zero
      , transform [ (scale 0) ]
      , pointerEvents none
      , position absolute
      , overflow visible
      , height (pct 100)
      , width (pct 100)
      , left (pct 50)
      , top (pct 50)
      , opacity 0
      , zIndex 1
      ]
    ]
  }
