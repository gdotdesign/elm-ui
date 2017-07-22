module Ui.Styles.Dropdown exposing (..)

{-| Styles for a drop-down.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a drop-down.
-}
style : Style
style =
  [ backgroundColor (varf "ui-dropdown-panel-background" "colors-input-background")
  , border ((px 1) . solid . (varf "ui-dropdown-panel-border" "border-color"))
  , borderRadius (varf "ui-dropdown-panel-border-radius" "border-radius")
  , fontFamily (varf "ui-dropdown-panel-font-family" "font-family")
  , color (varf "ui-dropdown-panel-text" "colors-input-text")
  , zIndex (var "ui-dropdown-panel-z-index" "1000")

  , pointerEvents none
  , visibility hidden
  , position fixed
  , display block
  , opacity 0

  , boxShadow
    [ { color = "rgba(0,0,0,0.1)"
      , blur = (px 20)
      , inset = False
      , spread = zero
      , y = (px 5)
      , x = zero
      }
    ]

  , transform
    [ translate3d zero zero zero, translateY (px 10)
    ]

  , transition
    [ { property = "opacity"
      , duration = (ms 150)
      , easing = "ease"
      , delay = (ms 0)
      }
    , { property = "transform"
      , duration = (ms 150)
      , easing = "ease"
      , delay = (ms 0)
      }
    , { property = "visibility"
      , duration = (ms 1)
      , delay = (ms 150)
      , easing = "ease"
      }
    ]

  , selector "&[open]"
    [ pointerEvents auto
    , visibility visible
    , opacity 1

    , transform
      [ translate3d zero zero zero, translateY zero
      ]

    , transition
      [ { property = "opacity"
        , duration = (ms 150)
        , easing = "ease"
        , delay = (ms 0)
        }
      , { property = "transform"
        , duration = (ms 150)
        , easing = "ease"
        , delay = (ms 0)
        }
      , { property = "visibility"
        , duration = (ms 1)
        , easing = "ease"
        , delay = (ms 0)
        }
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-dropdown-panel"
