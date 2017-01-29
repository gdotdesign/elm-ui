module Ui.Styles.ColorPicker exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.ColorPanel as ColorPanel
import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ ColorPanel.style theme
    , Picker.style theme

    , selector "*[ui-color-picker]"
      [ selector "ui-color-panel"
        [ borderColor transparent
        ]

      , selector "ui-picker-input"
        [ paddingRight (px 52)
        ]
      ]

    , selector "ui-color-picker-text"
      [ Mixins.ellipsis
      ]
    ]
