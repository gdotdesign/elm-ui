module Ui.Styles.ColorPanel exposing (..)

{-| Styles for a color panel.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a color panel.
-}
style : Style
style =
  [ Mixins.defaults

  , backgroundColor (varf "ui-color-panel-background" "colors-input-background")
  , border ((px 1) . solid . (varf "ui-color-panel-border" "border-color"))
  , borderRadius (varf "ui-color-panel-border-radius" "border-radius")
  , fontFamily (varf "ui-color-panel-font-family" "font-family")
  , color (varf "ui-color-panel-text" "colors-input-text")
  , transform [ translate3d zero zero zero ]
  , flexDirection column
  , userSelect none
  , padding (px 15)
  , width (px 260)
  , display flex

  , selector "&[readonly]"
    [ Mixins.readonly

    , selector "ui-color-panel-hsv"
      [ pointerEvents none
      ]
    ]

  , selector "&[disabled]"
    [ Mixins.disabled

    , background (varf "ui-color-panel-disabled-background" "colors-disabled-background")
    , borderColor transparent

    , selector "ui-color-panel-hsv"
      [ property "-webkit-filter" "saturate(0)"
      , property "filter" "saturate(0)"
      , pointerEvents none
      , opacity 0.6
      ]

    , selector "ui-color-panel-handle"
      [ opacity 0.6
      ]

    , selector "ui-color-fields"
      [ borderTopColor "rgba(0, 0, 0, 0.1)"

      , selector "input"
        [ backgroundColor (var "ui-calendar-disabled-input-background" "#A9A9A9")
        , color (var "ui-calendar-disabled-input-text" "#CECECE")
        ]
      ]
    ]

  , selector "ui-color-panel-handle"
    [ Mixins.defaults

    , border ((px 2) . solid . (varf "ui-color-handle-border" "colors-input-background"))
    , transform [ translate (pct -50) (pct -50) ]
    , background "rgba(102, 102, 102, 0.6)"
    , borderRadius (pct 50)
    , pointerEvents none
    , position absolute
    , height (px 16)
    , width (px 16)

    , boxShadow
      [ { color = "rgba(0,0,0,0.5)"
        , spread = zero
        , blur = (px 4)
        , inset = False
        , x = zero
        , y = zero
        }
      ]
    ]

  , selector "ui-color-fields"
    [ borderTop ((px 1) . solid . (varf "ui-color-panel-border" "border-color"))
    , paddingTop (px 10)
    , marginTop (px 10)
    ]

  , selector "ui-color-panel-hsv"
    [ flexDirection column
    , display flex
    , flex_ "1"

    , selector "ui-color-panel-box"
      [ marginBottom (px 15)
      , display "flex"
      , flex_ "1"
      ]

    , selector "ui-color-panel-alpha"
      [ backgroundColor "#DDD"
      , property "background-image"
         ( "linear-gradient(45deg, #F5F5F5 25%, transparent 25%, transparent 75%, #F5F5F5 75%, #F5F5F5),"
          ++ "linear-gradient(45deg, #F5F5F5 25%, transparent 25%, transparent 75%, #F5F5F5 75%, #F5F5F5)" )
      , borderRadius (varf "ui-color-panel-border-radius" "border-radius")
      , property "background-position" "0 0, 9px 9px"
      , property "background-size" "18px 18px"
      , position relative
      , cursor colResize
      , flex_ "0 0 16px"

      , selector "ui-color-panel-alpha-background"
        [ borderRadius (varf "ui-color-panel-border-radius" "border-radius")
        , pointerEvents none
        , height (px 16)
        , display block
        , boxShadow
          [ { color = "rgba(0,0,0,0.2)"
            , spread = (px 1)
            , blur = (px 1)
            , inset = True
            , x = zero
            , y = zero
            }
          ]
        ]

      , selector "ui-color-panel-handle"
        [ borderRadius (varf "ui-color-panel-border-radius" "border-radius")
        , transform [ translateX (pct -50) ]
        , bottom (px -4)
        , width (px 10)
        , top (px -4)
        , height auto
        ]
      ]

    , selector "ui-color-panel-hue"
      [ background
        ("linear-gradient(to bottom, #F00 0%, #FF0 17%, #0F0 33%," ++
         "#0FF 50%, #00F 67%, #F0F 83%, #F00 100%)" )
      , borderRadius (varf "ui-color-panel-border-radius" "border-radius")
      , position relative
      , cursor rowResize
      , flex_ "0 0 16px"
      , boxShadow
        [ { color = "rgba(0,0,0,0.4)"
          , spread = (px 1)
          , blur = (px 1)
          , inset = True
          , x = zero
          , y = zero
          }
        ]

      , selector "ui-color-panel-handle"
        [ borderRadius (varf "ui-color-panel-border-radius" "border-radius")
        , transform [ translateY (pct -50)]
        , height (px 10)
        , right (px -4)
        , left (px -4)
        , width auto
        ]
      ]

    , selector "ui-color-panel-rect"
      [ background
        ("linear-gradient(0deg, #000 0%, transparent 100%)," ++
         "linear-gradient(90deg, #FFF 0%, rgba(0,0,0,0) 100%)")
      , boxShadow
        [ { color = "rgba(0,0,0,0.2)"
          , spread = (px 1)
          , blur = (px 1)
          , inset = True
          , x = zero
          , y = zero
          }
        ]
      , borderRadius (varf "ui-color-panel-border-radius" "border-radius")
      , marginRight (px 15)
      , position relative
      , height (px 197)
      , cursor pointer
      , flex_ "1"
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-color-panel"
