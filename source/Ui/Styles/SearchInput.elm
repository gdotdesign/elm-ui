module Ui.Styles.SearchInput exposing (..)

{-| Styles for a search-input.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input
import Ui.Styles exposing (Style)

{-| Styles for a search-input using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a search-input using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , display inlineBlock
    , position relative
    , height (px 36)

    , selector "> svg"
      [ fill theme.colors.input.bw
      , position absolute
      , height (px 14)
      , width (px 14)
      , left (px 12)
      , top (px 11)
      ]

    , selector "ui-input"
      [ width (pct 100)

      , selector "input"
        [ paddingLeft (px 34)
        ]
      ]
    ]
