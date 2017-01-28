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
    ]
