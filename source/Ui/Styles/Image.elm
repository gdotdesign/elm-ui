module Ui.Styles.Image exposing (..)

{-| Styles for an image.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles exposing (Style)

{-| Styles for an image using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for an image using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
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
