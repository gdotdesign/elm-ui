module Ui.Styles.Button exposing (..)

{-| Styles for a button.

@docs style, variables
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme, default)
import Ui.Styles.Ripple as Ripple
import Ui.Styles.Mixins as Mixins
import Ui.Styles

import Html

{-| Variables for the styles of a button.
-}
variables : List (String, String)
variables =
  [ ("ui-button-border-radius", default.borderRadius)
  , ("ui-button-font-family", default.fontFamily)
  , ("ui-button-primary-background", default.colors.primary.color)
  , ("ui-button-primary-color", default.colors.primary.bw)
  , ("ui-button-disabled-background", default.colors.disabled.color)
  , ("ui-button-disabled-color", default.colors.disabled.bw)
  , ("ui-button-secondary-background", default.colors.secondary.color)
  , ("ui-button-secondary-color", default.colors.secondary.bw)
  , ("ui-button-warning-background", default.colors.warning.color)
  , ("ui-button-warning-color", default.colors.warning.bw)
  , ("ui-button-danger-background", default.colors.danger.color)
  , ("ui-button-danger-color", default.colors.danger.bw)
  , ("ui-button-success-background", default.colors.success.color)
  , ("ui-button-success-color", default.colors.success.bw)
  ]
    |> Ui.Styles.registerVariables


{-| Returns the styles for a button.
-}
style : List (Html.Attribute msg)
style =
  [ Mixins.defaults
  , Ripple.style

  , borderRadius (var "ui-button-border-radius")
  , fontFamily (var "ui-button-font-family")
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
    [ backgroundColor (var "ui-button-disabled-background")
    , color (var "ui-button-disabled-color")
    , Mixins.disabled
    ]

  , selector "&[readonly]"
    [ Mixins.readonly ]

  , selector "&:not([disabled])"
    [ selector "&[kind=primary]"
      [ backgroundColor (var "ui-button-primary-background")
      , color (var "ui-button-primary-color")
      ]

    , selector "&[kind=secondary]"
      [ backgroundColor (var "ui-button-secondary-background")
      , color (var "ui-button-secondary-color")
      ]

    , selector "&[kind=warning]"
      [ backgroundColor (var "ui-button-warning-background")
      , color (var "ui-button-warning-color")
      ]

    , selector "&[kind=success]"
      [ backgroundColor (var "ui-button-success-background")
      , color (var "ui-button-success-color")
      ]

    , selector "&[kind=danger]"
      [ backgroundColor (var "ui-button-danger-background")
      , color (var "ui-button-danger-color")
      ]
    ]
  ]
    |> mixin
    |> Ui.Styles.attributes
    |> Ui.Styles.apply
