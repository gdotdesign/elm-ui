module Ui.Styles.Textarea exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  selector "ui-textarea"
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
      , bottom (px -24)
      , height (px 24)
      , content ""
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
      ]

    , selector "ui-textarea-mirror"
      [ Mixins.defaults

      , padding ((px 6) . (px 9))
      , wordWrap breakWord
      , whiteSpace normal
      , visibility hidden
      , userSelect none
      , display block

      , selector "span-line:empty:before"
        [ content "a"
        ]
      ]
    ]
