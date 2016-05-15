module Ui.Layout exposing (..)

{-| Module that provides most commonly used layouts.

@docs sidebar, default, centerDefault
-}

import Html.Attributes exposing (class)
import Html exposing (node)

import Ui.Header


{-| Layout with a sidebar on the left side.

    Ui.Layout.sidebar sidebarContent mainContent
-}
sidebar : List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
sidebar sidebarContent mainContent =
  node
    "ui-layout"
    [ class "ui-layout-sidebar" ]
    [ node "ui-layout-sidebar" [] sidebarContent
    , node "ui-layout-main" [] mainContent
    ]


{-| Layout with header, content and footer, where the content fills the empty
space (sticky footer).

    Ui.Layout.default headerContent mainContent footerContent
-}
default : List (Html.Html msg) -> List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
default headerContent mainContent footerContent =
  node
    "ui-layout"
    [ class "ui-layout-default" ]
    [ Ui.Header.view [] headerContent
    , node "ui-layout-main" [] mainContent
    , node "ui-layout-footer" [] footerContent
    ]


{-| Same as the default layout but content is centered in all three parts.

    Ui.Layout.centerDefault headerContent mainContent footerContent
-}
centerDefault : List (Html.Html msg) -> List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
centerDefault headerContent mainContent footerContent =
  node
    "ui-layout"
    [ class "ui-layout-center-default" ]
    [ Ui.Header.view [] [ node "ui-layout-center" [] headerContent ]
    , node "ui-layout-main" [] [ node "ui-layout-center" [] mainContent ]
    , node "ui-layout-footer" [] [ node "ui-layout-center" [] footerContent ]
    ]
