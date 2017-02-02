module Ui.Styles.Picker exposing (..)

{-| Styles for a picker.

@docs style
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Dropdown as Dropdown
import Ui.Styles.Mixins as Mixins

{-| Returns the style node for a picker using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.focusedIdle theme

    , border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , borderRadius theme.borderRadius
    , fontFamily theme.fontFamily
    , color theme.colors.input.bw
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
      [ Mixins.focused theme
      ]

    , selector "&[readonly] ui-picker-input"
      [ Mixins.readonly
      ]

    , selector "&[disabled] ui-picker-input"
      [ Mixins.disabledColors theme
      , Mixins.disabled

      , property "-webkit-filter" "saturate(0)"
      , property "filter" "saturate(0)"
      , borderColor transparent
      ]
    ]
