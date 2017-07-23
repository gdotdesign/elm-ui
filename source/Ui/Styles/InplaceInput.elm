module Ui.Styles.InplaceInput exposing (..)

{-| Styles for an inplace input.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for an inplace input.
-}
style : Style
style =
  [ display inlineBlock

  , selector "ui-textarea"
    [ zIndex "0"
    ]

  , selector "ui-button[kind=primary]"
    [ marginRight (px 10)
    ]

  , selector "ui-button[kind=secondary]"
    [ marginLeft auto
    ]

  , selector "ui-inplace-input-content"
    [ fontFamily (varf "ui-inplace-input-font-family" "font-family")
    , color (varf "ui-inplace-input-text" "colors-input-text")
    , padding ((px 6) . (px 9))
    , wordBreak breakWord
    , lineHeight (px 24)
    , whiteSpace preWrap
    , display block

    , selector "&:empty:before"
      [ content "attr(placeholder)"
      , opacity 0.5
      ]
    ]

  , selector "&:not([disabled]):not([readonly])"
    [ selectors
      [ "ui-inplace-input-content"
      , "ui-inplace-input-content:empty:before"
      ]
      [ cursor pointer
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-inplace-input"
