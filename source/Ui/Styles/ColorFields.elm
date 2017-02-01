module Ui.Styles.ColorFields exposing (..)

{-| Styles for a color fields.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a color fields using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a color fields using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , justifyContent spaceBetween
    , fontFamily theme.fontFamily
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
      [ Mixins.focusedIdle theme

      , border ((px 1) . solid . theme.colors.border)
      , backgroundColor theme.colors.input.color
      , property "-moz-appearance" "textfield"
      , padding ((px 3) . (px 4) . (px 4))
      , borderRadius theme.borderRadius
      , color theme.colors.input.bw
      , fontFamily theme.fontFamily
      , textTransform uppercase
      , boxSizing borderBox
      , lineHeight (px 14)
      , textAlign center
      , fontSize (px 13)
      , fontWeight bold
      , width (pct 100)
      , height (px 30)

      , selectors
        [ "&::-webkit-outer-spin-button"
        , "&::-webkit-inner-spin-button"
        ]
        [ display none
        ]

      , selector "&:focus"
        [ Mixins.focused theme ]

      , selector "&[readonly]"
        [ Mixins.readonly
        ]

      , selector "&[disabled]"
        [ Mixins.disabledColors theme
        , Mixins.disabled

        , border transparent
        ]
      ]
    ]
