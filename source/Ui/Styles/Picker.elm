module Ui.Styles.Picker exposing (..)

{-| Styles for a picker.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Dropdown as Dropdown
import Ui.Styles.Mixins as Mixins

{-| Returns the style for a picker.
-}
style : Node
style =
  mixin
    [ Mixins.focusedIdle

    , border ((px 1) . solid . (varf "ui-picker-border" "border-color"))
    , backgroundColor (varf "ui-picker-background" "colors-input-background")
    , borderRadius (varf "ui-picker-border-radius" "border-radius")
    , fontFamily (varf "ui-picker-font-family" "font-family")
    , color (varf "ui-picker-text" "colors-input-text")
    , display inlineBlock
    , minWidth (px 220)
    , height (px 36)

    , selector "ui-picker-input"
      [ padding ((px 6) . (px 9))
      , alignItems center
      , position relative
      , userSelect none
      , cursor pointer
      , height (px 24)
      , display flex
      , flex_ "1"
      ]

    , selector "&:focus"
      [ Mixins.focused
      ]

    , selector "&[readonly] ui-picker-input"
      [ Mixins.readonly
      ]

    , selector "&[disabled] ui-picker-input"
      [ Mixins.disabledColors "ui-picker"
      , Mixins.disabled

      , property "-webkit-filter" "saturate(0)"
      , property "filter" "saturate(0)"
      , borderColor transparent
      ]
    ]
