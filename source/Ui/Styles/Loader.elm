module Ui.Styles.Loader exposing (..)

{-| Styles for a loader.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a loader.
-}
style : Style
style =
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
      [ background (varf "ui-loader-rectangle-color" "colors-focus-background")
      , property "animation" "ui-loader-rects 0.6s infinite"
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
        ++ (varf "ui-loader-bar-color-1" "colors-primary-background")
        ++ ", "
        ++ (varf "ui-loader-bar-color-1" "colors-primary-background")
        ++ " 49.9999%, "
        ++ (varf "ui-loader-bar-color-2" "colors-focus-background")
        ++ " 50%, "
        ++ (varf "ui-loader-bar-color-2" "colors-focus-background")
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
  |> mixin
  |> Ui.Styles.attributes "ui-loader"

{-| Inflix 2 tuple.
-}
(=>) : a -> b -> ( a , b )
(=>) = (,)
