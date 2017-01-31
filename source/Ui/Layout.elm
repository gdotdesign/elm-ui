module Ui.Layout exposing (sidebar, app, website)

{-| Module that provides flexbox layouts for most common use cases.

# Views
@docs sidebar, app, website
-}
import Html.Attributes exposing (attribute)
import Html exposing (node)

import Ui.Styles.Layout exposing (defaultStyle)
import Ui.Styles

{-| Alias for list of Html elements.
-}
type alias Content msg =
  List (Html.Html msg)


{-| Layout with a sidebar on the left side.

    Ui.Layout.sidebar
      [ text "sidebar" ]
      [ text "content" ]
-}
sidebar : Content msg -> Content msg -> Html.Html msg
sidebar sidebarContent mainContent =
  node "ui-layout-sidebar"
    (Ui.Styles.apply defaultStyle)
    [ node "ui-layout-sidebar-bar"     [] sidebarContent
    , node "ui-layout-sidebar-content" [] mainContent
    ]


{-| Single page app layout with the a sidebar and a toolbar.

    Ui.Layout.app
      [ text "sidebar" ]
      [ text "toolbar" ]
      [ text "content" ]
-}
app : Content msg -> Content msg -> Content msg -> Html.Html msg
app sidebarContent toolbarContent mainContent =
  node "ui-layout-app"
    (Ui.Styles.apply defaultStyle)
    [ node "ui-layout-app-sidebar" [] sidebarContent
    , node "ui-layout-app-wrapper"
        []
        [ node "ui-layout-app-toolbar" [] toolbarContent
        , node "ui-layout-app-content" [] mainContent
        ]
    ]


{-| Website layout with a header and a sticky footer.

    Ui.Layout.website
      [ text "header" ]
      [ text "content" ]
      [ text "footer" ]
-}
website : Content msg -> Content msg -> Content msg -> Html.Html msg
website headerContent mainContent footerContent =
  node "ui-layout-website"
    ( [ Ui.Styles.apply defaultStyle
      , [ attribute "kind" "website" ]
      ]
      |> List.concat
    )
    [ node "ui-layout-website-header"  [] headerContent
    , node "ui-layout-website-content" [] mainContent
    , node "ui-layout-website-footer"  [] footerContent
    ]
