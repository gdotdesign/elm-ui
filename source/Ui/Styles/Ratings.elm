module Ui.Styles.Ratings exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  selector "ui-ratings"
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
