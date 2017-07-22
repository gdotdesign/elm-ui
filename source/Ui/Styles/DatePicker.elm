module Ui.Styles.DatePicker exposing (..)

{-| Styles for a date picker.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Picker as Picker
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a date picker.
-}
style : Style
style =
  [ Picker.style

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
  |> mixin
  |> Ui.Styles.attributes "[ui-date-picker]"
