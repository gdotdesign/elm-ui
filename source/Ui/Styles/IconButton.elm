module Ui.Styles.IconButton exposing (..)

{-| Styles for an icon-button.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Button as Button
import Ui.Styles exposing (Style)

{-| Styles for an icon-button using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for an icon-button using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Button.style theme

    , selector "ui-icon-button-icon + span:not(:empty)"
      [ marginLeft (em 0.625)
      ]

    , selector "span:not(:empty) + ui-icon-button-icon"
      [ marginLeft (em 0.625)
      ]

    , selector "ui-icon-button-icon"
      [ display inlineFlex

      , selector "> *"
        [ width inherit
        , height inherit
        ]
      , selector "svg"
        [ fill currentColor ]
      ]

    , selector "&[size=medium] ui-icon-button-icon"
      [ height (px 12)
      , width (px 12)
      ]

    , selector "&[size=big] ui-icon-button-icon"
      [ height (px 18)
      , width (px 18)
      ]

    , selector "&[size=small] ui-icon-button-icon"
      [ height (px 10)
      , width (px 10)
      ]
    ]
