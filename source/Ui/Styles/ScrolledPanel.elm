module Ui.Styles.ScrolledPanel exposing (..)

{-| Styles for a scrolled-panel.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles exposing (Style)

{-| Returns the style for a scrolled-panel.
-}
style : Style
style =
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
      [ borderRadius (varf "ui-scrolled-panel-border-radius" "border-radius")
      , background (var "ui-scrolled-panel-thumb" "#D0D0D0")
      , border zero
      ]

    , selector "&::-webkit-scrollbar-thumb:hover"
      [ background (var "ui-scrolled-panel-thumb-hover" "#B8B8B8")
      ]

    , selector "&::-webkit-scrollbar-track"
      [ borderRadius (varf "ui-scrolled-panel-border-radius" "border-radius")
      , background (var "ui-scrolled-panel-track" "#E9E9E9")
      , border zero
      ]

    , selector "&::-webkit-scrollbar-corner"
      [ background transparent
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-scrolled-panel"
