module Ui.Styles.Ratings exposing (..)

{-| Styles for a ratings.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a ratings using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a ratings using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , display inlineBlock
    , cursor pointer
    , height (px 36)
    , outline none

    , selector "ui-ratings-star"
      [ justifyContent center
      , display inlineFlex
      , alignItems center
      , height (px 36)
      , width (px 36)

      , selector "svg"
        [ fill theme.colors.input.bw
        , height (px 28)
        , width (px 28)
        ]
      ]

    , selector "&:not([disabled])"
      [ selectors
        [ "&:focus svg"
        , "&:hover svg"
        ]
        [ fill theme.colors.focus.color
        ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , selector "svg"
        [ fill theme.colors.disabled.color
        ]
      ]

    , selector "&[readonly]"
      [ Mixins.disabled
      ]
    ]
