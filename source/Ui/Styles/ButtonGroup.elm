module Ui.Styles.ButtonGroup exposing (..)

{-| Styles for a button group.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a button group using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a button group using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , selector "ui-button"
      [ selector "+ ui-button"
        [ borderLeft ((px 1) . solid . "rgba(0, 0, 0, 0.15)")
        ]

      , selector "&:not(:first-child):not(:last-child)"
        [ borderRadius (px 0)
        ]

      , selector "&:first-child"
        [ borderRadius
            (theme.borderRadius . (px 0) . (px 0) . theme.borderRadius)
        ]

      , selector "&:last-child"
        [ borderRadius
            ((px 0) . theme.borderRadius . theme.borderRadius . (px 0))
        ]
      ]
    ]
