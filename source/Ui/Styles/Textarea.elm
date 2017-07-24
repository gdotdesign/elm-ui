module Ui.Styles.Textarea exposing (..)

{-| Styles for an textarea.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)


{-| Returns the style for a textarea.
-}
style : Style
style =
  [ Mixins.defaults

  , fontFamily (varf "ui-textarea-font-family" "font-family")
  , color (varf "ui-textarea-text" "colors-input-text")
  , lineHeight (px 24)
  , position relative
  , overflow visible
  , minHeight (em 1)
  , display block

  , selector "ui-textarea-background"
    [ Mixins.focusedIdle
    , Mixins.defaults

    , backgroundColor (varf "ui-textarea-background" "colors-input-background")
    , border ((px 1) . solid . (varf "ui-textarea-border" "border-color"))
    , borderRadius (varf "ui-textarea-border-radius" "border-radius")

    , position absolute
    , bottom zero
    , right zero
    , zIndex "0"
    , left zero
    , top zero
    ]

  , selector "textarea:not([disabled]):focus + ui-textarea-background"
    [ Mixins.focused
    ]

  , selector "textarea[readonly]"
    [ Mixins.readonly
    ]

  , selector "textarea[disabled]"
    [ Mixins.disabled

    , color (varf "ui-textarea-disabled-text" "colors-disabled-text")

    , selector "+ ui-textarea-background"
      [ Mixins.disabledColors "ui-textarea"
      , borderColor transparent
      ]
    ]

  , selector "&:after"
    [ position absolute
    , contentString ""
    , bottom (px -24)
    , height (px 24)
    , right zero
    , zIndex "2"
    , left zero
    ]

  , selector "textarea"
    [ Mixins.defaults

    , height "calc(100% + 1em)"
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
    , zIndex "1"
    , left zero
    , top zero

    , Mixins.placeholder
      [ textOverflow ellipsis
      , whiteSpace nowrap
      , overflow hidden
      , display block
      , opacity 0.75
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
  |> mixin
  |> Ui.Styles.attributes "ui-textarea"
