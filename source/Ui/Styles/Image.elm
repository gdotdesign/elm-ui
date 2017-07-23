module Ui.Styles.Image exposing (..)

{-| Styles for an image.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles exposing (Style)

{-| Returns the style for an image.
-}
style : Style
style =
    [ display inlineBlock

    , selector "img"
      [ height inherit
      , width inherit
      , display block
      , opacity 0
      , transition
        [ { duration = (ms 320)
          , property = "all"
          , easing = "ease"
          , delay = (ms 0)
          }
        ]
      ]

    , selector "&[loaded] img"
      [ opacity 1
      ]
    ]
  |> mixin
  |> Ui.Styles.attributes "ui-image"
