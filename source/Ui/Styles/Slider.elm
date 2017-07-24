module Ui.Styles.Slider exposing (..)

{-| Styles for a slider.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a slider.
-}
style : Style
style =
  [ Mixins.defaults

  , minWidth (px 100)
  , alignItems center
  , position relative
  , cursor colResize
  , userSelect none
  , height (px 36)
  , display flex
  , outline none

  , selector "*"
    [ pointerEvents none
    ]

  , selector "ui-slider-bar"
    [ Mixins.focusedIdle

    , border ((px 1) . solid . (varf "ui-slider-border" "border-color"))
    , background (varf "ui-slider-background" "colors-input-background")
    , borderRadius (varf "ui-slider-border-radius" "border-radius")
    , position relative
    , height (px 18)
    , display block
    , flex_ "1"
    ]

  , selector "ui-slider-progress"
    [ backgroundColor (varf "ui-slider-progress" "colors-primary-background")
    , borderRadius (varf "ui-slider-border-radius" "border-radius")
    , borderRight ((px 6) . solid . transparent)
    , backgroundClip contentBox
    , boxSizing borderBox
    , position absolute
    , bottom (px 3)
    , left (px 3)
    , top (px 3)
    ]

  , selector "ui-slider-handle"
    [ boxShadow
      [ { color = "rgba(0,0,0,0.5)"
        , spread = zero
        , blur = (px 4)
        , inset = False
        , x = zero
        , y = zero
        }
      ]
    , border ((px 2) . solid . (varf "ui-slider-handle-border" "colors-input-background"))
    , borderRadius (varf "ui-slider-border-radius" "border-radius")
    , background "rgba(102,102,102,.5)"
    , boxSizing borderBox
    , marginLeft (px -4)
    , position absolute
    , bottom (px 3)
    , width (px 8)
    , top (px 3)
    ]

  , selector "&[readonly]"
    [ Mixins.readonly
    ]

  , selector "&[disabled]"
    [ Mixins.disabled

    , selector "ui-slider-bar"
      [ Mixins.disabledColors "ui-slider"
      ]

    , selector "ui-slider-progress"
      [ backgroundColor (varf "ui-slider-disabled-background" "colors-disabled-background")
      ]

    , selector "ui-slider-handle"
      [ opacity 0.6 ]
    ]

  , selector "&:focus ui-slider-bar"
    [ Mixins.focused
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-slider"
