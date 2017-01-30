module Ui.Styles.DropdownMenu exposing (style, defaultStyleAttributes)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Dropdown as Dropdown
import Ui.Styles.Mixins as Mixins
import Ui.Styles

import Lazy exposing (Lazy)
import Html

defaultStyleAttributes : List (Html.Attribute msg)
defaultStyleAttributes =
  Lazy.force defaultStyleAttributesLazy

defaultStyleAttributesLazy : Lazy (List (Html.Attribute msg))
defaultStyleAttributesLazy =
  Ui.Styles.attributes (style Theme.default)

style : Theme -> Node
style theme =
  mixin
    [ Dropdown.style theme
    , selector "ui-dropdown-menu-item"
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
