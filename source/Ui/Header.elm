module Ui.Header exposing (..)

{-| Header elements.

@docs view, icon, title, separator
-}
import Html.Attributes exposing (class, tabindex)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node, text)

import VirtualDom exposing (attribute)

import Ui

{-| Renders a header element. -}
view : List (Html.Attribute msg) -> List (Html.Html msg) -> (Html.Html msg)
view attributes children =
  node "ui-header" attributes children

{-| Renders a header icon element. -}
icon : String -> Bool -> List (Html.Attribute msg) -> (Html.Html msg)
icon glyph clickable attributes =
  node "ui-header-icon" (Ui.iconAttributes glyph clickable attributes) []

{-| Renders a header title element. -}
title : List (Html.Attribute msg) -> List (Html.Html msg) -> (Html.Html msg)
title attributes children =
  node "ui-header-title" attributes
    [node "div" [] children]

{-| Renders a header separator element. -}
separator : Html.Html msg
separator =
  node "ui-header-separator" [] []

item : String -> msg -> (Html.Html msg)
item content msg =
  node "ui-header-item" (itemAttributes msg) [text content]

iconItem : String -> msg -> String -> String -> (Html.Html msg)
iconItem content msg glyph side =
  let
    icon =
      Ui.icon glyph False []

    span =
      node "span" [] [text content]

    sideAttribute =
      attribute "side" side

    children =
      if side == "left" then [icon, span] else [span, icon]
  in
    node "ui-header-icon-item" (itemAttributes msg) children

itemAttributes msg =
  [ tabindex 0
  , onClick msg
  , onKeys [ (13, msg)
           , (32, msg)
           ]
  ]
