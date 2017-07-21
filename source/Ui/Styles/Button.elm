module Ui.Styles.Button exposing (..)

{-| Styles for a button.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Ripple as Ripple
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)


{-| Returns the style mixin for a button.
-}
base : Node
base =
  [ Mixins.defaults
  , Ripple.style

  , borderRadius (varf "ui-button-border-radius" "border-radius")
  , fontFamily (varf "ui-button-font-family" "font-family")
  , justifyContent center
  , display inlineFlex
  , alignItems center
  , textAlign center
  , fontWeight bold
  , userSelect none
  , cursor pointer
  , outline none

  , selector "span"
    [ Mixins.ellipsis
    , alignSelf stretch
    ]

  , selector "> *"
    [ pointerEvents none
    ]

  , selector "&[size=medium]"
    [ padding (zero . (px 24))
    , fontSize (px 16)
    , height (px 36)

    , selector "span"
      [ lineHeight (px 36) ]
    ]

  , selector "&[size=big]"
    [ padding (zero . (px 30))
    , fontSize (px 22)
    , height (px 50)

    , selector "span"
      [ lineHeight (px 52) ]
    ]

  , selector "&[size=small]"
    [ padding (zero . (px 16))
    , fontSize (px 12)
    , height (px 26)

    , selector "span"
      [ lineHeight (px 26) ]
    ]

  , selector "&[disabled]"
    [ Mixins.disabledColors "ui-buton"
    , Mixins.disabled
    ]

  , selector "&[readonly]"
    [ Mixins.readonly ]

  , selector "&:not([disabled])"
    [ selector "&[kind=primary]"
      [ backgroundColor (varf "ui-button-primary-background" "colors-primary-background")
      , color (varf "ui-button-primary-text" "colors-primary-text")
      ]

    , selector "&[kind=secondary]"
      [ backgroundColor (varf "ui-button-secondary-background" "colors-secondary-background")
      , color (varf "ui-button-secondary-text" "colors-secondary-text")
      ]

    , selector "&[kind=warning]"
      [ backgroundColor (varf "ui-button-warning-background" "colors-warning-background")
      , color (varf "ui-button-warning-text" "colors-warning-text")
      ]

    , selector "&[kind=success]"
      [ backgroundColor (varf "ui-button-success-background" "colors-success-background")
      , color (varf "ui-button-success-text" "colors-success-text")
      ]

    , selector "&[kind=danger]"
      [ backgroundColor (varf "ui-button-danger-background" "colors-danger-background")
      , color (varf "ui-button-danger-text" "colors-danger-text")
      ]
    ]
  ]
  |> mixin


{-| Returns the style node for a button.
-}
style : Style
style =
  Ui.Styles.attributes "ui-button" base
