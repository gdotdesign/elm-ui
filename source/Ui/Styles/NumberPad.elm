module Ui.Styles.NumberPad exposing (..)

{-| Styles for a number-pad.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a number-pad.
-}
style : Style
style =

  [ Mixins.defaults
  , Mixins.focusedIdle

  , backgroundColor (varf "ui-number-pad-background" "colors-input-background")
  , border ((px 1) . solid . (varf "ui-number-pad-border" "border-color"))
  , borderRadius (varf "ui-number-pad-border-radius" "border-radius")
  , fontFamily (varf "ui-number-pad-font-family" "font-family")
  , color (varf "ui-number-pad-text" "colors-input-text")
  , transform [ translate3d zero zero zero ]
  , flexDirection column
  , minHeight (px 350)
  , userSelect none
  , padding (px 10)
  , display flex

  , selector "ui-number-pad-value"
    [ border ((px 1) . solid . (varf "ui-number-pad-border" "border-color"))
    , borderRadius (varf "ui-number-pad-border-radius" "border-radius")
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
        [ fill (varf "ui-number-pad-hover" "colors-focus-background")
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
    [ backgroundColor (varf "ui-number-pad-button-background" "colors-input-secondary-background")
    , borderRadius (varf "ui-number-pad-border-radius" "border-radius")
    , width "calc((100% - 20px) / 3)"
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
      [ backgroundColor (varf "ui-number-pad-button-active-background" "colors-primary-background")
      , color (varf "ui-number-pad-button-active-text" "colors-primary-text")
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
    [ Mixins.focused
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
    , Mixins.disabledColors "ui-number-pad"
    , borderColor transparent

    , selectors
      [ "ui-number-pad-value"
      , "ui-number-pad-button"
      ]
      [ backgroundColor (var "ui-number-pad-button-disabled-background" "#CECECE")
      , color (var "ui-number-pad-button-disabled-text" "#A9A9A9")
      , borderColor transparent
      ]

    , selector "> *"
      [ pointerEvents none
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-number-pad"
