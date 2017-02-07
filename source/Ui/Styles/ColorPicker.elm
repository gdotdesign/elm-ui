module Ui.Styles.ColorPicker exposing (..)

{-| Styles for a color picker.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a color picker using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a color picker using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Picker.style theme

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
      , property "background-position" "0 0, 9px 9px"
      , property "background-size" "18px 18px"
      , borderRadius theme.borderRadius
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
        , borderRadius theme.borderRadius
        , flex_ "1"
        ]
      ]
    ]
