module Ui.Styles.IconButton exposing (..)

{-| Styles for an icon-button.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Button as Button
import Ui.Styles exposing (Style)

{-| Returns the style for an icon-button.
-}
style : Style
style =
  [ Button.base

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
  |> mixin
  |> Ui.Styles.attributes "ui-icon-button"
