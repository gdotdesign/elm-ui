module Ui.Styles.Textarea exposing (..)

{-| Styles for an textarea.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a textarea using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a textarea using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , fontFamily theme.fontFamily
    , color theme.colors.input.bw
    , lineHeight (px 24)
    , position relative
    , overflow visible
    , minHeight (em 1)
    , display block

    , selector "ui-textarea-background"
      [ Mixins.focusedIdle theme
      , Mixins.defaults

      , border ((px 1) . solid . theme.colors.border)
      , backgroundColor theme.colors.input.color
      , borderRadius theme.borderRadius

      , position absolute
      , bottom zero
      , right zero
      , left zero
      , zIndex 0
      , top zero
      ]

    , selector "textarea:not([disabled]):focus + ui-textarea-background"
      [ Mixins.focused theme
      ]

    , selector "textarea[readonly]"
      [ Mixins.readonly
      ]

    , selector "textarea[disabled]"
      [ Mixins.disabled

      , color theme.colors.disabled.bw

      , selector "+ ui-textarea-background"
        [ Mixins.disabledColors theme
        , borderColor transparent
        ]
      ]

    , selector "&:after"
      [ position absolute
      , contentString ""
      , bottom (px -24)
      , height (px 24)
      , right zero
      , left zero
      , zIndex 2
      ]

    , selector "textarea"
      [ Mixins.defaults

      , height "calc(100% + 24px)"
      , padding ((px 6) . (px 9))
      , background transparent
      , fontFamily inherit
      , lineHeight inherit
      , fontWeight inherit
      , position absolute
      , fontSize inherit
      , overflow hidden
      , width (pct 100)
      , color inherit
      , outline none
      , resize none
      , margin zero
      , border zero
      , left zero
      , top zero
      , zIndex 1

      , Mixins.placeholder
        [ textOverflow ellipsis
        , whiteSpace nowrap
        , overflow hidden
        , display block
        ]
      ]

    , selector "ui-textarea-mirror"
      [ Mixins.defaults

      , padding ((px 6) . (px 9))
      , wordWrap breakWord
      , whiteSpace normal
      , visibility hidden
      , userSelect none
      , display block

      , selector "span-line[empty]:before"
        [ contentString "a"
        ]
      ]
    ]
