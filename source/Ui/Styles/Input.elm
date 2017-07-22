module Ui.Styles.Input exposing (..)

{-| Styles for an input.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for an input using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes "ui-input" (style Theme.default)


{-| Returns the style node for an input using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
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
        [ fill currentColor
        , position absolute
        , height (px 12)
        , width (px 12)
        , right (px 12)
        , top (px 12)

        , selector "&:hover"
          [ fill theme.colors.focus.color
          , cursor pointer
          ]
        ]
      ]
    ]


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
