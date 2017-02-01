module Ui.Styles.Header exposing (..)

{-| Styles for a header.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Ripple as Ripple
import Ui.Styles exposing (Style)

{-| Styles for a header using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a header using the given theme.
-}
style theme =
  mixin
    [ background
        ( "linear-gradient(" ++
          theme.header.colors.backgroundTop  ++
          ", " ++
          theme.header.colors.backgroundBottom ++
          ")"
        )
      , zIndex theme.zIndexes.header
      , fontFamily theme.fontFamily
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
      [ background theme.header.colors.border
      , margin (zero . (px 8))
      , height (px 40)
      , width (px 2)
      ]

    , selector "ui-header-spacer"
      [ flex_ "1"
      ]

    , selector "ui-header-title"
      [ item theme
      , fontSize (px 20)
      ]

    , selector "ui-header-item"
      [ item theme
      ]

    , selector "ui-header-icon-item"
      [ item theme

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
      [ item theme

      , selector "svg:not([ripple])"
        [ fill currentColor
        , height (px 20)
        , width (px 20)
        ]
      ]
    ]


{-| Returns a style node for an header item.
-}
item : Theme -> Node
item theme =
  mixin
    [ property "-webkit-filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"
    , property "filter" "drop-shadow(0px 1px 0px rgba(0,0,0,0.3))"

    , color theme.header.colors.text
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
