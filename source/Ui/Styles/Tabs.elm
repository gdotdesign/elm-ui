module Ui.Styles.Tabs exposing (..)

{-| Styles for tabs.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for tabs using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for tabs using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , fontFamily theme.fontFamily
    , position relative
    , display block

    , selector "ui-tabs-handles"
      [ borderBottom ((px 1) . solid . theme.colors.border )
      , display flex
      ]

    , selector "ui-tabs-content"
      [ borderRadius (zero . zero . theme.borderRadius . theme.borderRadius )
      , border ((px 1) . solid . theme.colors.border )
      , backgroundColor theme.colors.input.color
      , color theme.colors.input.bw
      , padding ((px 15) . (px 20))
      , position relative
      , borderTop zero
      , display block
      , zIndex 1
      ]

    , selector "ui-tabs-handle"
      [ borderRadius (theme.borderRadius . theme.borderRadius . zero . zero)
      , backgroundColor theme.colors.inputSecondary.color
      , border ((px 1) . solid . theme.colors.border )
      , color theme.colors.inputSecondary.bw
      , padding ((px 10) . (px 20))
      , position relative
      , fontWeight bold
      , cursor pointer
      , outline none
      , top (px 1)

      , selector "&[selected]"
        [ backgroundColor theme.colors.input.color
        , color theme.colors.input.bw
        , borderBottom zero
        ]

      , selector "&:hover"
        [ color theme.colors.primary.color
        ]

      , selectors
        [ "&:focus"
        , "&[selected]:focus"
        ]
        [ color theme.colors.focus.color
        ]

      , selector "+ ui-tabs-handle"
        [ marginLeft (px 5)
        ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , selector "> *"
        [ pointerEvents none
        ]

      , selectors
        [ "ui-tabs-handle"
        , "ui-tabs-content"
        ]
        [ Mixins.disabledColors theme
        , borderColor theme.colors.borderDisabled
        ]
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selector "ui-tabs-content"
        [ pointerEvents none
        ]

      , selector "ui-tabs-handle"
        [ cursor inherit ]
      ]
    ]
