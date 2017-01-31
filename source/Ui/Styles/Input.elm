module Ui.Styles.Input exposing (..)

{-| Styles for an input.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for an input using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for an input using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , color theme.colors.input.bw
    , display inlineBlock
    , position relative

    , inputStyle theme

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
inputStyle : Theme -> Node
inputStyle theme =
  selector "input"
    [ Mixins.focusedIdle theme
    , Mixins.defaults

    , border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , borderRadius theme.borderRadius
    , fontFamily theme.fontFamily
    , color theme.colors.input.bw
    , padding ((px 6) . (px 9))
    , lineHeight (px 16)
    , fontSize (px 16)
    , width (pct 100)
    , height (px 36)

    , selector "&::-webkit-input-placeholder"
      [ lineHeight (px 22)
      ]

    , selector "&[disabled]"
      [ Mixins.disabledColors theme
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
      [ Mixins.focused theme
      ]
    ]
