module Ui.Styles.Container exposing (style, defaultStyle)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)

defaultStyle : Node
defaultStyle =
  style Theme.default

style : Theme -> Node
style theme =
  mixin
    [ display flex

    , selector "&[direction=row]"
      [ flexDirection row
      , selector "&:not([compact]) > * + *"
        [ marginLeft (px 10) ]
      ]

    , selector "&[direction=column]"
      [ flexDirection column
      , selector "&:not([compact]) > * + *"
        [ marginTop (px 10) ]
      ]

    , selector "&[align=start]"
      [ justifyContent flexStart
      ]

    , selector "&[align=center]"
      [ justifyContent center
      ]

    , selector "&[align=space-between]"
      [ justifyContent spaceBetween
      ]

    , selector "&[align=space-around]"
      [ justifyContent spaceAround
      ]

    , selector "&[align=end]"
      [ justifyContent flexEnd
      ]
    ]
