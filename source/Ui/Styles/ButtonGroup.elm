module Ui.Styles.ButtonGroup exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Button as Button

style : Theme -> Node
style theme =
  mixin
    [ Button.style theme
    , selector "ui-button-group"
      [ selector "ui-button"
        [ borderRadius (px 0)
        , selector "+ ui-button"
          [ borderLeft ((px 1) . solid . "rgba(0, 0, 0, 0.15)")
          ]
        , selector "&:first-child"
          [ borderRadius (theme.borderRadius . (px 0) . (px 0) . theme.borderRadius)
          ]
        , selector "&:last-child"
          [ borderRadius ((px 0) . theme.borderRadius . theme.borderRadius . (px 0))
          ]
        ]
      ]
    ]
