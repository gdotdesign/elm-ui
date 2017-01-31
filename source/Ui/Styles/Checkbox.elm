module Ui.Styles.Checkbox exposing (..)

{-| Styles for a checkbox.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a checkbox using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a checkbox using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults
    , Mixins.focusedIdle theme

    , fontFamily theme.fontFamily

    , border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , color theme.colors.input.bw
    , display inlineBlock
    , cursor pointer

    , selector "&[readonly]"
      [ Mixins.readonly ]

    , selector "&[disabled]"
      [ Mixins.disabledColors theme
      , Mixins.disabled

      , borderColor transparent
      ]

    , selector "&:focus"
      [ Mixins.focused theme
      ]

    , selector "&[kind=checkbox]"
      [ borderRadius theme.borderRadius
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
        [ fill theme.colors.primary.color ]

      , selector "&[checked] svg"
        [ transform [ (scale 1) ]
        , opacity 1
        ]
      ]

    , selector "&[kind=toggle]"
      [ borderRadius theme.borderRadius
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
        , backgroundColor theme.colors.primary.color
        , borderRadius theme.borderRadius
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
        [ backgroundColor theme.colors.disabledSecondary.color ]

      , selector "&:focus ui-checkbox-toggle-handle"
        [ backgroundColor theme.colors.focus.color ]
      ]

    , selector "&[kind=radio]"
      [ borderRadius (pct 50)
      , position relative
      , height (px 36)
      , width (px 36)

      , selector "ui-checkbox-radio-circle"
        [ transform [ (scale 0.4) ]
        , opacity 0

        , backgroundColor theme.colors.primary.color
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
        [ backgroundColor theme.colors.disabledSecondary.color ]

      , selector "&:focus ui-checkbox-radio-circle"
        [ backgroundColor theme.colors.focus.color ]
      ]
    ]
