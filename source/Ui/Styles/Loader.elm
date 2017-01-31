module Ui.Styles.Loader exposing (..)

{-| Styles for a loader.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a loader using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a loader using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , keyframes "ui-loader-bar"
      [ "0%" =>
        [ backgroundPositionX zero
        ]
      , "100%" =>
        [ backgroundPositionX (px 200)
        ]
      ]

    , keyframes "ui-loader-rects"
      [ "0%" =>
        [ transform [ translateY zero ]
        ]
      , "50%" =>
        [ transform [ translateY (px 20) ]
        ]
      , "100%" =>
        [ transform [ translateY zero ]
        ]
      ]

    , visibility hidden
    , display block
    , opacity 0
    , transition
      [ { property = "all"
        , duration = (ms 320)
        , delay = (ms 0)
        , easing = "ease"
        }
      ]

    , selector "&[loading]"
      [ opacity 1
      , visibility visible
      ]

    , selector "&[kind=overlay]"
      [ justifyContent center
      , alignItems center
      , position absolute
      , display flex
      , bottom zero
      , right zero
      , left zero
      , top zero

      , selector "ui-loader-rectangles"
        [ justifyContent spaceBetween
        , transform [ scale 1.5 ]
        , overflow hidden
        , height (px 24)
        , display flex
        , width (px 22)
        ]

      , selector "ui-loader-rectangle"
        [ property "animation" "ui-loader-rects 0.6s infinite"
        , background theme.colors.focus.color
        , display inlineBlock
        , height (px 10)
        , width (px 4)

        , selector "&:nth-child(2)"
          [ property "animation-delay" "-0.2s"
          ]

        , selector "&:nth-child(3)"
          [ property "animation-delay" "-0.3s"
          ]
        ]
      ]

    , selector "&[kind=bar]"
      [ background
          ("linear-gradient( 90deg, "
          ++ theme.colors.primary.color
          ++ ", "
          ++ theme.colors.primary.color
          ++ " 49.9999%, "
          ++ theme.colors.focus.color
          ++ " 50%, "
          ++ theme.colors.focus.color
          ++ ")")
      , backgroundSize ((px 200) . (px 5))
      , height (px 5)

      , animation
        [ { iterationCount = "infinite"
          , name = "ui-loader-bar"
          , playState = "running"
          , duration = (ms 1000)
          , direction = "normal"
          , fillMode = "both"
          , easing = "linear"
          , delay = (ms 0)
          }
        ]
      ]
    ]


{-| Inflix 2 tuple.
-}
(=>) : a -> b -> ( a , b )
(=>) = (,)
