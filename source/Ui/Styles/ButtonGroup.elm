module Ui.Styles.ButtonGroup exposing (..)

{-| Styles for a button group.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

import Html.Styles exposing (Style, styles, selector)
import Html

{-| Styles for a button group using the default theme.
-}
defaultStyle : Html.Attribute msg
defaultStyle =
  style Theme.default


{-| Returns the style node for a button group using the given theme.
-}
style : Theme -> Html.Attribute msg
style theme =
  styles
    Mixins.defaults
    [ selector "ui-button + ui-button"
      [ borderLeft ((px 1) . solid . "rgba(0, 0, 0, 0.15)")
      ]

    , selector "ui-button:not(:first-child):not(:last-child)"
      [ borderRadius (px 0)
      ]

    , selector "ui-button:first-child"
      [ borderRadius
          (theme.borderRadius . (px 0) . (px 0) . theme.borderRadius)
      ]

    , selector "ui-button:last-child"
      [ borderRadius
          ((px 0) . theme.borderRadius . theme.borderRadius . (px 0))
      ]
    ]
