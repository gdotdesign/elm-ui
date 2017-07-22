module Ui.Styles.ColorPicker exposing (..)

{-| Styles for a color picker.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)


{-| Returns the style for a color picker.
-}
style : Style
style =
  [ Picker.style

  , selector "ui-color-panel"
    [ borderColor transparent
    ]

  , selector "ui-picker-input"
    [ paddingRight (px 52)
    ]

  , selector "ui-color-picker-text"
    [ Mixins.ellipsis
    ]

  , selector "ui-color-picker-rect"
    [ backgroundColor "#DDD"
    , property "background-image"
       ( "linear-gradient(45deg, #F5F5F5 25%, transparent 25%, transparent 75%, #F5F5F5 75%, #F5F5F5),"
        ++ "linear-gradient(45deg, #F5F5F5 25%, transparent 25%, transparent 75%, #F5F5F5 75%, #F5F5F5)" )
    , borderRadius (varf "ui-color-picker-border-radius" "border-radius")
    , property "background-position" "0 0, 9px 9px"
    , property "background-size" "18px 18px"
    , position absolute
    , display flex
    , width (px 36)
    , bottom (px 5)
    , right (px 4)
    , top (px 4)

    , selector "ui-color-picker-background"
      [ boxShadow
        [ { color = "rgba(0,0,0,0.2)"
          , spread = (px 1)
          , blur = (px 1)
          , inset = True
          , y = zero
          , x = zero
          }
        ]
      , borderRadius (varf "ui-color-picker-border-radius" "border-radius")
      , flex_ "1"
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "[ui-color-picker]"
