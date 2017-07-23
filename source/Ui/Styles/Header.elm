module Ui.Styles.Header exposing (..)

{-| Styles for a header.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles.Ripple as Ripple
import Ui.Styles exposing (Style)

{-| Returns the style for a header.
-}
style : Style
style =
  [ background (varf "ui-header-background" "colors-primary-background")
  , fontFamily (varf "ui-header-font-family" "font-family")
  , zIndex (var "ui-header-z-index" "50")
  , padding (zero . (px 20))
  , position relative
  , flex_ "0 0 auto"

  , flexDirection row
  , alignItems center
  , display flex

  , height (px 60)

  , boxShadow
    [ { color = "rgba(0,0,0,0.1)"
      , blur = (px 3)
      , inset = False
      , spread = zero
      , y = (px 2)
      , x = zero
      }
    , { color = "rgba(0,0,0,0.1)"
      , blur = (px 10)
      , inset = False
      , spread = zero
      , y = zero
      , x = zero
      }
    ]

  , selector "ui-header-separator"
    [ background (var "ui-header-separator" "#137FC2")
    , margin (zero . (px 8))
    , height (px 40)
    , width (px 2)
    ]

  , selector "ui-header-spacer"
    [ flex_ "1"
    ]

  , selector "ui-header-title"
    [ item
    , fontSize (px 20)
    ]

  , selector "ui-header-item"
    [ item
    ]

  , selector "ui-header-icon-item"
    [ item

    , selector "svg:not([ripple])"
      [ fill currentColor
      , height (px 20)
      , width (px 20)
      ]

    , selectors
      [ "svg + span"
      , "span + svg"
      ]
      [ marginLeft (px 12)
      ]
    ]

  , selector "ui-header-icon"
    [ item

    , selector "svg:not([ripple])"
      [ fill currentColor
      , height (px 20)
      , width (px 20)
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-header"


{-| Returns a style node for an header item.
-}
item : Node
item =
  mixin
    [ property "-webkit-filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"
    , property "filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"

    , color (varf "ui-header-text" "colors-primary-text")
    , margin (zero . (px 2))
    , fontSize (px 18)
    , fontWeight bold
    , height inherit

    , selector "&[interactive] a"
      [ Ripple.style

      , borderRight ((px 1) . solid . transparent)
      , borderLeft ((px 1) . solid . transparent)
      , transform [ translate3d zero zero zero ]
      , textDecoration none
      , color currentColor
      , position relative
      , cursor pointer
      , transition
        [ { duration = (ms 200)
          , property = "all"
          , easing = "ease"
          , delay = (ms 0)
          }
        ]

      , selector "&:focus"
        [ borderColor "rgba(0,0,0,0.6)"
        , outline none
        , transition
          [ { duration = (ms 200)
            , delay = (ms 100)
            , property = "all"
            , easing = "ease"
            }
          ]
        ]

      , selector "&:active"
        [ borderColor "rgba(0,0,0,0.6)"
        ]
      ]

    , selector "&:not([interactive]) svg[ripple]"
      [ display none
      ]

    , selector "span"
      [ height (px 18)
      ]

    , selector "a"
      [ padding (zero . (px 12))
      , textOverflow ellipsis
      , alignItems center
      , whiteSpace nowrap
      , fontSize inherit
      , userSelect none
      , height inherit
      , display flex
      ]
    ]
