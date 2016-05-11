module Ui.Layout exposing (..)

import Html.Attributes exposing (class)
import Html exposing (node)

import Ui.Header

sidebar : Int -> List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
sidebar size sidebarContent mainContent =
  node "ui-layout" [class "ui-layout-sidebar"]
    [ node "ui-layout-sidebar" [] sidebarContent
    , node "ui-layout-main" [] mainContent
    ]


default : List (Html.Html msg) -> List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
default headerContent mainContent footerContent =
  node "ui-layout" [class "ui-layout-default"]
    [ Ui.Header.view [] headerContent
    , node "ui-layout-main" [] mainContent
    , node "ui-layout-footer" [] footerContent
    ]


centerDefault : List (Html.Html msg) -> List (Html.Html msg) -> List (Html.Html msg) -> Html.Html msg
centerDefault headerContent mainContent footerContent =
  node "ui-layout" [class "ui-layout-center-default"]
    [ Ui.Header.view [] [ node "ui-layout-center" [] headerContent ]
    , node "ui-layout-main" [] [ node "ui-layout-center" [] mainContent ]
    , node "ui-layout-footer" [] [ node "ui-layout-center" [] footerContent ]
    ]
