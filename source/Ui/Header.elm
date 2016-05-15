module Ui.Header exposing (view, icon, title, separator, item, iconItem)

{-| Static elements for creating application headers.

# View
@docs view

# Elements
@docs icon, title, separator

# Navigation Items
@docs item, iconItem
-}

import Html.Attributes exposing (attribute, tabindex)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)

import Ui


{-| Renders a header element.

    Ui.Header.view [] [ text "Hello" ]
-}
view : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
view attributes children =
  node "ui-header" attributes children


{-| Renders a header icon element.

    Ui.Header.icon "social-github" OpenGithub []
-}
icon : String -> Bool -> List (Html.Attribute msg) -> Html.Html msg
icon glyph clickable attributes =
  node "ui-header-icon" (Ui.iconAttributes glyph clickable attributes) []


{-| Renders a header title element.

    Ui.Header.title "Elm-UI Rocks!"
-}
title : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
title attributes children =
  node
    "ui-header-title"
    attributes
    [ node "div" [] children ]


{-| Renders a header separator element.

    Ui.Header.separator
-}
separator : Html.Html msg
separator =
  node "ui-header-separator" [] []


{-| Renders a header navigation item.

    Ui.Header.item "Github" OpenGithub
-}
item : String -> msg -> Html.Html msg
item content msg =
  node "ui-header-item" (itemAttributes msg) [ text content ]


{-| Renders an header navigation item with an icon.

    Ui.Header.iconItem "Github" OpenGithub "social-github" "left"
-}
iconItem : String -> msg -> String -> String -> Html.Html msg
iconItem content msg glyph side =
  let
    icon =
      Ui.icon glyph False []

    span =
      node "span" [] [ text content ]

    sideAttribute =
      attribute "side" side

    children =
      if side == "left" then
        [ icon, span ]
      else
        [ span, icon ]
  in
    node "ui-header-icon-item" (itemAttributes msg) children


{-| Returns attributes for an item.
-}
itemAttributes : msg -> List (Html.Attribute msg)
itemAttributes msg =
  [ tabindex 0
  , onClick msg
  , onKeys
      [ ( 13, msg )
      , ( 32, msg )
      ]
  ]
