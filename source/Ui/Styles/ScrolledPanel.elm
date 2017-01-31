module Ui.Styles.ScrolledPanel exposing (..)

{-| Styles for a scrolled-panel.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles exposing (Style)

{-| Styles for a scrolled-panel using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a scrolled-panel using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ maxHeight inherit
    , position relative
    , height inherit
    , display flex
    , flex_ "1"

    , selector "ui-scrolled-panel-wrapper"
      [ paddingRight (px 5)
      , maxHeight inherit
      , overflowY scroll
      , height inherit
      , flex_ "1"

      , selector "&::-webkit-scrollbar"
        [ height (px 10)
        , width (px 10)
        ]

      , selector "&::-webkit-scrollbar-button"
        [ height zero
        , width zero
        ]

      , selector "&::-webkit-scrollbar-thumb"
        [ background theme.scrollbar.thumbColor
        , borderRadius theme.borderRadius
        , border zero
        ]

      , selector "&::-webkit-scrollbar-thumb:hover"
        [ background theme.scrollbar.thumbHoverColor
        ]

      , selector "&::-webkit-scrollbar-track"
        [ background theme.scrollbar.trackColor
        , borderRadius theme.borderRadius
        , border zero
        ]

      , selector "&::-webkit-scrollbar-corner"
        [ background transparent
        ]
      ]
    ]
