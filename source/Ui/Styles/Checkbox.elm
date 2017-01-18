module Ui.Styles.Checkbox exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ selectors
      [ "ui-checkbox"
      , "ui-checkbox-toggle"
      , "ui-checkbox-radio"
      ]
      [ Mixins.focusedIdle theme
      , border ((px 1) . solid . theme.colors.border)
      , backgroundColor theme.colors.input.color
      , color theme.colors.input.bw
      , display inlineBlock
      , cursor pointer

      , selector "&[readonly]"
        [ Mixins.readonly ]

      , selector "&[disabled]"
        [ Mixins.disabledColors theme
        , Mixins.disabled
        ]

      , selector "&:focus"
        [ Mixins.focused theme
        ]
      ]

    , selector "ui-checkbox"
      [ borderRadius theme.borderRadius
      , height (px 36)
      , width (px 36)
      ]

    , selector "ui-checkbox-radio"
      [ borderRadius (pct 50)
      , position relative
      , height (px 36)
      , width (px 36)

      , selector "ui-checkbox-radio-circle"
        [ transform [ (scale 0.4) ]
        , opacity 0

        , backgroundColor theme.colors.primary.color
        , borderRadius (pct 50)
        , position absolute
        , bottom (px 8)
        , right (px 8)
        , left (px 8)
        , top (px 8)

        , transition
          [ { easing = "cubic-bezier(0.215, 0.61, 0.355, 1)"
            , duration = ms 200
            , property = "all"
            , delay = ms 0
            }
          ]
        ]

      , selector "&[checked] ui-checkbox-radio-circle"
        [ transform [ (scale 1) ]
        , opacity 1
        ]
      ]
  ]
