module Ui.Fab exposing (view)

{-| This module provides a view for a floating action button.

# View
@docs view
-}
import Html exposing (node)

import Ui.Styles.Fab exposing (defaultStyle)
import Ui.Styles

{-| Renders a floating action button.

    Ui.Fab.view (Ui.Icons.plus []) [ onClick Open ]
-}
view : Html.Html msg -> List (Html.Attribute msg) -> Html.Html msg
view glyph attributes =
  node
    "ui-fab"
    ( [ Ui.Styles.apply defaultStyle
      , attributes
      ]
      |> List.concat
    )
    [ glyph ]
