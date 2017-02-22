module Ui.Styles.Breadcrumbs exposing (..)

{-| Styles for breadcrumbs.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

import Html.Styles exposing (styles, selector)
import Html

{-| Styles for breadcrumbs using the default theme.
-}
defaultStyle : Html.Attribute msg
defaultStyle =
  style Theme.default

{-| Returns the style node for breadcrumbs using the given theme.
-}
style : Theme -> Html.Attribute msg
style theme =
  styles
    ( [ Mixins.defaults
      , [ borderBottom ((px 1) . solid . theme.breadcrumbs.borderColor)
        , background theme.breadcrumbs.background
        , color theme.breadcrumbs.text
        , fontFamily theme.fontFamily
        , padding (px 15)
        , display block
        ]
      ]
      |> List.concat
    )
    [ selector "ui-breadcrumb"
      [ display inlineBlock
      ]

    , selector "ui-breadcrumb:not([clickable])"
      [ pointerEvents none
      ]

    , selector "ui-breadcrumb a"
      [ textDecoration none
      , color currentColor
      , cursor pointer
      , outline none
      ]

    , selector "ui-breadcrumb:hover"
      [ color theme.colors.primary.color
      ]

    , selector "ui-breadcrumb:focus"
      [ color theme.colors.focus.color
      ]

    , selector "ui-breadcrumb-separator"
      [ margin (zero . (px 10))
      , opacity 0.5
      ]
    ]
