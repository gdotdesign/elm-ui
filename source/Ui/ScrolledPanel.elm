module Ui.ScrolledPanel exposing (view)

{-| This module provides a view for scrolled panels.

@docs view
-}
import Html exposing (node)

{-| Renders a panel that have scrolling content.

    Ui.ScrolledPanel.view [ text "Long scrollable text..." ]
-}
view : List (Html.Html msg) -> Html.Html msg
view contents =
  node
    "ui-scrolled-panel"
    []
    [ node "ui-scrolled-panel-wrapper" [] contents ]
