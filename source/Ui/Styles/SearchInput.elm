module Ui.Styles.SearchInput exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input

style : Theme -> Node
style theme =
  mixin
    [ Input.style theme

    , selector "ui-search-input"
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

      , selector "ui-input input"
        [ paddingLeft (px 34)
        ]
      ]
    ]
