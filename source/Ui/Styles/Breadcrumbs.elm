module Ui.Styles.Breadcrumbs exposing (..)

{-| Styles for breadcrumbs.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style node for breadcrumbs using the given theme.
-}
style : Style
style =
  [ Mixins.defaults

  , borderBottom ((px 1) . solid . (var "ui-breadcrumbs-border-color" "#D2D2D2"))
  , fontFamily (varf "ui-breadcrumbs-font-family" "font-family")
  , background (var "ui-breadcrumbs-background" "#F1F1F1")
  , color (var "ui-breadcrumb-text" "#4A4A4A")
  , padding (px 15)
  , display block

  , selector "ui-breadcrumb"
    [ display inlineBlock

    , selector "&:not([clickable])"
      [ pointerEvents none
      ]

    , selector "a"
      [ textDecoration none
      , color currentColor
      , cursor pointer
      , outline none

      , selector "&:hover"
        [ color (varf "ui-breadcrumbs-hover" "colors-primary-background")
        ]

      , selector "&:focus"
        [ color (varf "ui-breadcrumbs-focus" "colors-focus-background")
        ]
      ]
    ]

  , selector "ui-breadcrumb-separator"
    [ margin (zero . (px 10))
    , opacity 0.5
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-breadcrumbs"
