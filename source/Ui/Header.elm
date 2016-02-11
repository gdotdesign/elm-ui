module Ui.Header where

{-| Header elements.

@docs view, icon, title, separator
-}
import Html.Attributes exposing (class)
import Html exposing (node, text)

import Ui

{-| Renders a header element. -}
view : List Html.Attribute -> List Html.Html -> Html.Html
view attributes children =
  node "ui-header" attributes children

{-| Renders a header icon element. -}
icon : String -> Bool -> List Html.Attribute -> Html.Html
icon glyph clickable attributes =
  node "ui-header-icon" (Ui.iconAttributes glyph clickable attributes) []

{-| Renders a header title element. -}
title : List Html.Attribute -> List Html.Html -> Html.Html
title attributes children =
  node "ui-header-title" attributes
    [node "div" [] children]

{-| Renders a header separator element. -}
separator : Html.Html
separator =
  node "ui-header-separator" [] []

item : String -> List Html.Attribute -> Html.Html
item content attributes =
  node "ui-header-item" attributes [text content]

iconItem : String -> String -> String -> List Html.Attribute -> Html.Html
iconItem content glyph side attributes =
  let
    attrs = class ("ui-header-item-" ++ side) :: attributes
  in
    node "ui-header-item" attrs
      [ Ui.icon glyph False []
      , text content
      ]
