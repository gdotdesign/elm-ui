module Ui.Styles.Breadcrumbs exposing (..)

{-| Styles for breadcrumbs.

@docs style, variables
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (default)
import Ui.Styles.Mixins as Mixins
import Ui.Styles

import Html

{-| Variables for the styles of a button.
-}
variables : List (String, String)
variables =
  [ ("ui-breadcrumbs-background-color", default.breadcrumbs.background)
  , ("ui-breadcrumbs-border-color", default.breadcrumbs.borderColor)
  , ("ui-breadcrumbs-hover-color", default.colors.primary.color)
  , ("ui-breadcrumbs-focus-color", default.colors.focus.color)
  , ("ui-breadcrumbs-text-color", default.breadcrumbs.text)
  , ("ui-breadcrumbs-font-family", default.fontFamily)
  ]
    |> Ui.Styles.registerVariables


{-| Returns the style node for breadcrumbs using the given theme.
-}
style : List (Html.Attribute msg)
style =
  [ Mixins.defaults

  , borderBottom ((px 1) . solid . (var "ui-breadcrumbs-border-color"))
  , background (var "ui-breadcrumbs-background-color")
  , fontFamily (var "ui-breadcrumbs-font-family")
  , color (var "ui-breadcrumbs-text-color")
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
        [ color (var "ui-breadcrumbs-hover-color")
        ]

      , selector "&:focus"
        [ color (var "ui-breadcrumbs-focus-color")
        ]
      ]
    ]

  , selector "ui-breadcrumb-separator"
    [ margin (zero . (px 10))
    , opacity 0.5
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes
  |> Ui.Styles.apply
