module Ui.Styles.Container exposing (style, defaultStyle)

{-| Styles for a container.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles exposing (Style)

{-| Styles for a container using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a container using the given theme.
-}
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
