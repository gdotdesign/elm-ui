module Ui.Styles.InplaceInput exposing (..)

{-| Styles for an inplace input.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for an inplace input using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for an inplace input using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ display inlineBlock

    , selector "ui-textarea"
      [ zIndex 0 ]

    , selector "ui-button[kind=primary]"
      [ marginRight (px 10)
      ]

    , selector "ui-button[kind=secondary]"
      [ marginLeft auto
      ]

    , selector "ui-inplace-input-content"
      [ fontFamily theme.fontFamily
      , color theme.colors.input.bw
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
