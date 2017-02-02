module Ui.Styles.DropdownMenu exposing (..)

{-| Styles for a drop-down menu.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a drop-down menu using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a drop-down menu using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ display inlineBlock

    , selector "ui-dropdown-menu-item"
      [ padding ((px 10) . (px 14))
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

      , selector "svg"
        [ fill currentColor
        , height (px 16)
        , width (px 16)
        ]

      , selector "ui-dropdown-menu-items"
        [ padding (px 7) ]
      ]
    ]
