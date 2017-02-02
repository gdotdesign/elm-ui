module Ui.ScrolledPanel exposing (view)

{-| This module provides a view for scrolled panels.

# View
@docs view
-}
import Html exposing (node)

import Ui.Styles.ScrolledPanel exposing (defaultStyle)
import Ui.Styles

{-| Renders a panel that have scrolling content.

    Ui.ScrolledPanel.view [ text "Long scrollable text..." ]
-}
view : List (Html.Attribute msg) ->  List (Html.Html msg) -> Html.Html msg
view attributes contents =
  node
    "ui-scrolled-panel"
    ( [ Ui.Styles.apply defaultStyle
      , attributes
      ]
      |> List.concat
    )
    [ node "ui-scrolled-panel-wrapper" [] contents ]
