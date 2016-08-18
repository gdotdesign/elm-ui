module Ui.Header exposing (view, icon, title, separator, item, iconItem)

{-| Static elements for creating application headers.

# View
@docs view

# Elements
@docs icon, title, separator

# Navigation Items
@docs item, iconItem
-}

import Html.Attributes exposing (attribute, tabindex, style)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)

import Ui.Helpers.Ripple as Ripple

import Ui


type alias Title msg =
  { action : Maybe msg
  , text : String
  }


type alias Icon msg =
  { action : Maybe msg
  , glyph : String
  , size : Float
  }


type alias IconItem msg =
  { action : Maybe msg
  , glyph : String
  , text : String
  , side : String
  }


type alias Item msg =
  Title msg


{-| Renders a header element.

    Ui.Header.view [] [ text "Hello" ]
-}
view : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
view attributes children =
  node "ui-header" attributes children


{-| Renders a header icon element.

    Ui.Header.icon "social-github" OpenGithub
-}
icon : Icon msg -> Html.Html msg
icon model =
  node "ui-header-icon"
    ( (Ui.iconAttributes model.glyph True []) ++
      (itemAttributes model) ++
      [style [("font-size", (toString model.size) ++ "px")]]
    )
    [ Ripple.view ]


{-| Renders a header title element.

    Ui.Header.title "Elm-UI Rocks!" Home
-}
title : Title msg -> Html.Html msg
title model =
  node
    "ui-header-title"
    (itemAttributes model)
    [ node "div" [] [text model.text]
    , Ripple.view
    ]


{-| Renders a header separator element.

    Ui.Header.separator
-}
separator : Html.Html msg
separator =
  node "ui-header-separator" [] []


{-| Renders a header navigation item.

    Ui.Header.item "Github" OpenGithub
-}
item : Item msg -> Html.Html msg
item model =
  node "ui-header-item"
    (itemAttributes model)
    [ text model.text
    , Ripple.view
    ]


{-| Renders an header navigation item with an icon.

    Ui.Header.iconItem "Github" OpenGithub "social-github" "left"
-}
iconItem : IconItem msg -> Html.Html msg
iconItem model =
  let
    icon =
      Ui.icon model.glyph False []

    span =
      node "span" [] [ text model.text ]

    children =
      if model.side == "left" then
        [ icon, span ]
      else
        [ span, icon ]
  in
    node "ui-header-icon-item"
      (itemAttributes model)
      (children ++ [ Ripple.view ])


{-| Returns attributes for an item.
-}
itemAttributes : { model | action : Maybe msg } -> List (Html.Attribute msg)
itemAttributes { action } =
  case action of
    Just msg ->
      [ tabindex 0
      , onClick msg
      , attribute "interactive" ""
      , onKeys
          [ ( 13, msg )
          , ( 32, msg )
          ]
      ]
    _ ->
      []
