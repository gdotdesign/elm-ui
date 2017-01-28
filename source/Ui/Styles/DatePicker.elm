module Ui.Styles.DatePicker exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Calendar as Calendar
import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ Calendar.style theme
    , Picker.style theme

    , selector "*[ui-date-picker] ui-calendar"
      [ borderColor transparent
      ]

    , selector "ui-date-picker-content"
      [ Mixins.ellipsis

      , marginRight (px 10)

      , selector "+ svg"
        [ fill currentColor
        , marginLeft auto
        , height (px 16)
        , width (px 16)
        ]
      ]
    ]
