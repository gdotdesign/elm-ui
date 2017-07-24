module Ui.Styles.Ratings exposing (..)

{-| Styles for a ratings.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a ratings.
-}
style : Style
style =
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
      [ fill (varf "ui-ratings-color" "colors-input-text")
      , height (px 28)
      , width (px 28)
      ]
    ]

  , selector "&:not([disabled])"
    [ selectors
      [ "&:focus svg"
      , "&:hover svg"
      ]
      [ fill (varf "ui-ratings-hover-color" "colors-focus-background")
      ]
    ]

  , selector "&[disabled]"
    [ Mixins.disabled

    , selector "svg"
      [ fill (varf "ui-ratings-disabled-color" "colors-disabled-background")
      ]
    ]

  , selector "&[readonly]"
    [ Mixins.disabled
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-ratings"
