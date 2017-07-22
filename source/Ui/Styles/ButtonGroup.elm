module Ui.Styles.ButtonGroup exposing (..)

{-| Styles for a button group.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)


{-| Returns the style for a button group.
-}
style : Style
style =
  let
    borderRadiusVar = varf "ui-button-group-border-radius" "border-radius"
  in
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
            (borderRadiusVar . (px 0) . (px 0) . borderRadiusVar)
        ]

      , selector "&:last-child"
        [ borderRadius
            ((px 0) . borderRadiusVar . borderRadiusVar . (px 0))
        ]
      ]
    ]
    |> mixin
    |> Ui.Styles.attributes "ui-button-group"
