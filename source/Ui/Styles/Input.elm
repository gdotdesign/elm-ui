module Ui.Styles.Input exposing (..)

{-| Styles for an input.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for an input.
-}
style : Style
style =
  [ Mixins.defaults

  , display inlineBlock
  , position relative

  , selector "input"
    [ base "ui-input"
    ]

  , selector "&[clearable]"
    [ selector "input"
      [ paddingRight (px 30) ]

    , selector "svg"
      [ fill (varf "ui-input-text" "colors-input-text")
      , position absolute
      , height (px 12)
      , width (px 12)
      , right (px 12)
      , top (px 12)

      , selector "&:hover"
        [ fill (varf "ui-input-hover" "colors-focus-background")
        , cursor pointer
        ]
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-input"


{-| Returns a style node for an input element.
-}
base : String -> Node
base prefix =
  mixin
    [ Mixins.focusedIdle
    , Mixins.defaults

    , border ((px 1) . solid . (varf (prefix ++ "-border-color") "border-color"))
    , backgroundColor (varf (prefix ++ "-background-color") "colors-input-background")
    , borderRadius (varf (prefix ++ "-border-radius") "border-radius")
    , fontFamily (varf (prefix ++ "-font-family") "font-family")
    , color (varf (prefix ++ "-text") "colors-input-text")
    , padding ((px 6) . (px 9))
    , lineHeight (px 16)
    , fontSize (px 16)
    , width (pct 100)
    , height (px 36)

    , selector "&::-webkit-input-placeholder"
      [ lineHeight (px 22)
      ]

    , Mixins.placeholder
      [ opacity 0.75
      ]

    , selector "&[disabled]"
      [ Mixins.disabledColors prefix
      , Mixins.disabled

      , borderColor transparent
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selectors
        [ "&::-moz-selection"
        , "&::selection"
        ]
        [ background transparent
        ]
      ]

    , selector "&:focus"
      [ Mixins.focused
      ]
    ]
