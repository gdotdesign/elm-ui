module Ui.Styles.Container exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

style : Node
style =
  selector "ui-container"
    [ display flexDisplay

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
