module Ui.Styles.Checkbox exposing (..)

{-| Styles for a checkbox.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a checkbox.
-}
style : Style
style =
  [ Mixins.defaults
  , Mixins.focusedIdle

  , border ((px 1) . solid . (varf "ui-checkbox-border-color" "border-color"))
  , backgroundColor (varf "ui-checkbox-background" "colors-input-background")
  , fontFamily (varf "ui-checkbox-font-family" "font-family")
  , color (varf "ui-checkbox-text" "colors-input-text")
  , display inlineBlock
  , cursor pointer

  , selector "&[readonly]"
    [ Mixins.readonly ]

  , selector "&[disabled]"
    [ Mixins.disabledColors "ui-checkbox"
    , Mixins.disabled

    , borderColor transparent
    ]

  , selector "&:focus"
    [ Mixins.focused
    ]

  , selector "&[kind=checkbox]"
    [ borderRadius (varf "ui-checkbox-border-radius" "border-radius")
    , justifyContent center
    , alignItems center
    , display flex
    , height (px 36)
    , width (px 36)

    , selector "svg"
      [ transition
        [ { duration = ms 200
          , property = "all"
          , easing = "ease"
          , delay = ms 0
          }
        ]

      , transform [ (scale 0.4), (rotate 45) ]
      , fill currentColor
      , height (px 16)
      , width (px 16)
      , opacity 0
      ]

    , selector "&:focus svg"
      [ fill (varf "ui-checkbox-focus-color" "colors-focus-background") ]

    , selector "&[checked] svg"
      [ transform [ (scale 1) ]
      , opacity 1
      ]
    ]

  , selector "&[kind=toggle]"
    [ borderRadius (varf "ui-checkbox-border-radius" "border-radius")
    , justifyContent center
    , display inlineFlex
    , alignItems center
    , position relative
    , minWidth (px 76)
    , height (px 36)

    , selector "ui-checkbox-toggle-bg"
      [ height inherit
      , display flex
      , flex_ "1"

      , selector "ui-checkbox-toggle-span"
        [ justifyContent center
        , alignItems center
        , fontSize (px 12)
        , fontWeight bold
        , display flex
        , flex_ "1"
        ]
      ]

    , selector "ui-checkbox-toggle-handle"
      [ transition
        [ { duration = ms 200
          , property = "all"
          , easing = "ease"
          , delay = ms 0
          }
        ]
      , backgroundColor (varf "ui-checkbox-primary-color" "colors-primary-background")
      , borderRadius (varf "ui-checkbox-border-radius" "border-radius")
      , width "calc(50% - 5px)"
      , position absolute
      , display block
      , bottom (px 5)
      , left (px 5)
      , top (px 5)
      ]

    , selector "&[checked] ui-checkbox-toggle-handle"
      [ left (pct 50) ]

    , selector "&[disabled] ui-checkbox-toggle-handle"
      [ backgroundColor (var "ui-checkbox-disabled-secondary" "#A9A9A9") ]

    , selector "&:focus ui-checkbox-toggle-handle"
      [ backgroundColor (varf "ui-checkbox-focus-color" "colors-focus-background") ]
    ]

  , selector "&[kind=radio]"
    [ borderRadius (pct 50)
    , position relative
    , height (px 36)
    , width (px 36)

    , selector "ui-checkbox-radio-circle"
      [ transform [ (scale 0.4) ]
      , opacity 0

      , backgroundColor (varf "ui-checkbox-primary-background" "colors-primary-background")
      , borderRadius (pct 50)
      , position absolute
      , bottom (px 8)
      , right (px 8)
      , left (px 8)
      , top (px 8)

      , transition
        [ { easing = "cubic-bezier(0.215, 0.61, 0.355, 1)"
          , duration = ms 200
          , property = "all"
          , delay = ms 0
          }
        ]
      ]

    , selector "&[checked] ui-checkbox-radio-circle"
      [ transform [ (scale 1) ]
      , opacity 1
      ]

    , selector "&[disabled] ui-checkbox-radio-circle"
      [ backgroundColor (var "ui-checkbox-disabled-secondary" "#A9A9A9") ]

    , selector "&:focus ui-checkbox-radio-circle"
      [ backgroundColor (varf "ui-checkbox-focus-color" "colors-focus-background") ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-checkbox"
