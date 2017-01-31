module Ui.Styles.DatePicker exposing (..)

{-| Styles for a date picker.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a container using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a container using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Picker.style theme

    , selector "ui-calendar"
      [ borderColor transparent
      ]

    , selector "ui-date-picker-content"
      [ Mixins.ellipsis

      , marginRight (px 10)

      , selector "+ svg"
        [ fill currentColor
        , marginLeft auto
        , height (px 16)
        , width (px 16)
        ]
      ]
    ]
