module Ui.Styles.SearchInput exposing (..)

{-| Styles for a search-input.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles exposing (Style)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input

{-| Returns the style for a search-input.
-}
style : Style
style =
  [ Mixins.defaults

  , display inlineBlock
  , position relative
  , height (px 36)

  , selector "> svg"
    [ fill (varf "ui-input-text" "colors-input-text")
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
  |> mixin
  |> Ui.Styles.attributes "ui-search-input"
