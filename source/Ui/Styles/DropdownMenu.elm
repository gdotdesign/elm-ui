module Ui.Styles.DropdownMenu exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Dropdown as Dropdown
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ Dropdown.style theme
    , selector "ui-dropdown-menu"
      [ selector "ui-dropdown-menu-item"
        [ padding ((px 9) . (px 14))
        , display flex

        , selector "+ ui-dropdown-menu-item"
          [ borderTop ((px 1) . solid . theme.colors.border)
          ]

        , selector "> * + *"
          [ marginLeft (px 10)
          ]

        , selector "&:hover"
          [ color theme.colors.focus.color
          , cursor pointer
          ]

        , selector "ui-dropdown-menu-items"
          [ padding (px 7) ]
        ]
      ]
    ]
