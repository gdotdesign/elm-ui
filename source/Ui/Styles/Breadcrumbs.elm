module Ui.Styles.Breadcrumbs exposing (..)

{-| Styles for breadcrumbs.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for breadcrumbs using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for breadcrumbs using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , borderBottom ((px 1) . solid . theme.breadcrumbs.borderColor)
    , background theme.breadcrumbs.background
    , color theme.breadcrumbs.text
    , fontFamily theme.fontFamily
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
          [ color theme.colors.primary.color
          ]

        , selector "&:focus"
          [ color theme.colors.focus.color
          ]
        ]
      ]

    , selector "ui-breadcrumb-separator"
      [ margin (zero . (px 10))
      , opacity 0.5
      ]
    ]
