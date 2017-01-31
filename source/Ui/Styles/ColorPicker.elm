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
    ]
