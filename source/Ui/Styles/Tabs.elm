module Ui.Styles.Tabs exposing (..)

{-| Styles for tabs.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for tabs.
-}
style : Style
style =
  [ Mixins.defaults

  , fontFamily (varf "ui-tabs-font-family" "font-family")
  , position relative
  , display block

  , selector "ui-tabs-handles"
    [ borderBottom ((px 1) . solid . (varf "ui-tabs-border" "border-color"))
    , display flex
    ]

  , selector "ui-tabs-content"
    [ borderRadius
      ( zero .
        zero .
        (varf "ui-tabs-border-radius" "border-radius") .
        (varf "ui-tabs-border-radius" "border-radius")
      )
    , backgroundColor (varf "ui-tabs-content-background" "colors-input-background")
    , border ((px 1) . solid . (varf "ui-tabs-border" "border-color"))
    , color (varf "ui-tabs-content-text" "colors-input-text")
    , padding ((px 15) . (px 20))
    , position relative
    , borderTop zero
    , display block
    , zIndex "1"
    ]

  , selector "ui-tabs-handle"
    [ borderRadius
      ( (varf "ui-tabs-border-radius" "border-radius") .
        (varf "ui-tabs-border-radius" "border-radius") .
        zero .
        zero
      )
    , backgroundColor (varf "ui-tabs-handle-background" "colors-input-secondary-background")
    , color (varf "ui-tabs-handle-text" "colors-input-secondary-text")
    , border ((px 1) . solid . (varf "ui-tabs-border" "border-color"))
    , padding ((px 10) . (px 20))
    , position relative
    , fontWeight bold
    , cursor pointer
    , outline none
    , top (px 1)

    , selector "&[selected]"
      [ backgroundColor (varf "ui-tabs-handle-selected-background" "colors-input-background")
      , color (varf "ui-tabs-handle-selected-text" "colors-input-text")
      , borderBottom zero
      ]

    , selector "&:hover"
      [ color (varf "ui-tabs-handle-hover-text" "colors-primary-background")
      ]

    , selectors
      [ "&:focus"
      , "&[selected]:focus"
      ]
      [ color (varf "ui-tabs-handle-focus-text" "colors-focus-background")
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
      [ Mixins.disabledColors "ui-tabs"
      , borderColor (varf "ui-tabs-border-disabled" "disabled-border-color")
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
  |> mixin
  |> Ui.Styles.attributes "ui-tabs"
