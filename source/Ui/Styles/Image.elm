module Ui.Styles.Image exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)

style : Theme -> Node
style theme =
  selector "ui-image"
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
