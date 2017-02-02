module Ui.Styles.Dropdown exposing (..)

{-| Styles for a drop-down.

@docs style
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a drop-down menu using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a drop-down using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , borderRadius theme.borderRadius
    , fontFamily theme.fontFamily
    , color theme.colors.input.bw

    , zIndex theme.zIndexes.dropdown
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
