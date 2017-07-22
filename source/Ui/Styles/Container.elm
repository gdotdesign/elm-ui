module Ui.Styles.Container exposing (style)

{-| Styles for a container.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles exposing (Style)

{-| Returns the style for a container.
-}
style : Style
style =
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
  |> mixin
  |> Ui.Styles.attributes "ui-container"
