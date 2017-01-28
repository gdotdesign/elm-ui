module Ui.Styles.Picker exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Dropdown as Dropdown
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ Dropdown.style theme

    , selector "ui-picker"
      [ Mixins.focusedIdle theme

      , border ((px 1) . solid . theme.colors.border)
      , backgroundColor theme.colors.input.color
      , borderRadius theme.borderRadius
      , fontFamily theme.fontFamily
      , color theme.colors.input.bw
      , display inlineFlex
      , minWidth (px 220)
      , height (px 36)

      , selector "ui-picker-input"
        [ padding ((px 6) . (px 9))
        , lineHeight (px 23)
        , position relative
        , userSelect none
        , cursor pointer
        , display block
        ]

      , selector "&:focus"
        [ Mixins.focused theme
        ]

      , selector "&[readonly] ui-picker-input"
        [ Mixins.readonly
        ]
      ]
    ]
