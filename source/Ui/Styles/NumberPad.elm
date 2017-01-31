module Ui.Styles.NumberPad exposing (..)

{-| Styles for a number-pad.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a number-pad using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a number-pad using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults
    , Mixins.focusedIdle theme

    , border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , transform [ translate3d zero zero zero ]
    , borderRadius theme.borderRadius
    , fontFamily theme.fontFamily
    , color theme.colors.input.bw
    , flexDirection column
    , minHeight (px 350)
    , userSelect none
    , padding (px 10)
    , display flex

    , selector "ui-number-pad-value"
      [ border ((px 1) . solid . theme.colors.border)
      , borderRadius theme.borderRadius
      , padding ((px 10) . (px 15))
      , marginBottom (px 10)
      , display flex

      , selector "span"
        [ marginRight (px 15)
        , fontSize (px 24)
        , fontWeight bold
        , flex_ "1"
        ]

      , selector "svg"
        [ fill currentColor
        , cursor pointer
        , height (px 26)
        , width (px 26)

        , selector "&:hover"
          [ fill theme.colors.focus.color
          ]
        ]
      ]

    , selector "ui-number-pad-buttons"
      [ justifyContent spaceBetween
      , flexWrap wrap
      , display flex
      , flex_ "1"
      ]

    , selector "ui-number-pad-button"
      [ backgroundColor theme.colors.inputSecondary.color
      , width "calc((100% - 20px) / 3)"
      , borderRadius theme.borderRadius
      , marginBottom (px 10)
      , fontSize (px 20)
      , fontWeight bold
      , cursor pointer

      , justifyContent center
      , alignItems center
      , display flex

      , transition
        [ { duration = (ms 200)
          , property = "all"
          , easing = "ease"
          , delay = (ms 0)
          }
        ]

      , selector "> * "
        [ flex_ "1"
        ]

      , selector "&:nth-child(n+10)"
        [ marginBottom zero
        ]

      , selector "&:empty"
        [ backgroundColor transparent
        , pointerEvents none
        , cursor auto
        ]

      , selector "&:active"
        [ backgroundColor theme.colors.primary.color
        , color theme.colors.primary.bw
        , transition
          [ { duration = (ms 50)
            , property = "all"
            , easing = "ease"
            , delay = (ms 0)
            }
          ]
        ]

      ]

    , selector "&:not([disabled]):focus"
      [ Mixins.focused theme
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selectors
        [ "ui-number-pad-value"
        , "ui-number-pad-button"
        ]
        [ pointerEvents none
        ]

      ]

    , selector "&[disabled]"
      [ Mixins.disabled
      , Mixins.disabledColors theme
      , borderColor transparent

      , selectors
        [ "ui-number-pad-value"
        , "ui-number-pad-button"
        ]
        [ backgroundColor theme.colors.disabledSecondary.color
        , color theme.colors.disabledSecondary.bw
        , borderColor transparent
        ]

      , selector "> *"
        [ pointerEvents none
        ]
      ]
    ]
