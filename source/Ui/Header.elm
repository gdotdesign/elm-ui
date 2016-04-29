module Ui.Header where

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

item : Signal.Address a -> String -> a -> Html.Html
item address content action =
  node "ui-header-item" (itemAttributes address action) [text content]

iconItem : Signal.Address a -> String -> a -> String -> String -> Html.Html
iconItem address content action glyph side =
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
    node "ui-header-icon-item" (itemAttributes address action) children

itemAttributes address action =
  [ tabindex 0
  , onClick address action
  , onKeys address [ (13, action)
                   , (32, action)
                   ]
  ]
