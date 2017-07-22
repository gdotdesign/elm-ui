module Ui.Styles.ColorFields exposing (..)

{-| Styles for a color fields.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)
import Ui.Styles.Input as Input

{-| Returns the style for a color fields.
-}
style : Style
style =
  [ Mixins.defaults

  , fontFamily (varf "ui-color-fields-font-family" "font-family")
  , justifyContent spaceBetween
  , display flex

  , selector "&[disabled]"
    [ Mixins.disabled

    , selector "ui-color-fields-label"
      [ opacity 0.6
      ]
    ]

  , selector "&[readonly]"
    [ Mixins.readonly
    ]

  , selector "ui-color-fields-column"
    [ flex_ "1 0 35px"

    , selector " + ui-color-fields-column"
      [ marginLeft (px 5)
      ]

    , selector "&:first-child"
      [ flex_ "1 0 65px"
      ]
    ]

  , selector "ui-color-fields-label"
    [ textTransform uppercase
    , marginTop (px 5)
    , textAlign center
    , fontSize (px 12)
    , fontWeight bold
    , userSelect none
    , display block
    ]

  , selector "input"
    [ property "-moz-appearance" "textfield"
    , padding ((px 3) . (px 4) . (px 4))
    , textTransform uppercase
    , lineHeight (px 14)
    , textAlign center
    , fontSize (px 13)
    , fontWeight bold
    , width (pct 100)
    , height (px 30)

    , Input.base "ui-color-fields"

    , selectors
      [ "&::-webkit-outer-spin-button"
      , "&::-webkit-inner-spin-button"
      ]
      [ display none
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-color-fields"
