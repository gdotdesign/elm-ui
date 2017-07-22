module Ui.Styles.DropdownMenu exposing (..)

{-| Styles for a drop-down menu.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a drop-down menu.
-}
style : Style
style =
  [ display inlineBlock

  , selector "ui-dropdown-menu-item"
    [ padding ((px 10) . (px 14))
    , display flex

    , selector "+ ui-dropdown-menu-item"
      [ borderTop ((px 1) . solid . (varf "ui-dropdown-menu-border" "border-color"))
      ]

    , selector "> * + *"
      [ marginLeft (px 10)
      ]

    , selector "&:hover"
      [ color (varf "ui-dropdown-menu-item-hover-text" "colors-focus-background")
      , cursor pointer
      ]

    , selector "svg"
      [ fill currentColor
      , height (px 16)
      , width (px 16)
      ]

    , selector "ui-dropdown-menu-items"
      [ padding (px 7)
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-dropdown-menu"
