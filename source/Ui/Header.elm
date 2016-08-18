module Ui.Header exposing
  (Title, Icon, IconItem, Item, view, icon, title, separator, item, iconItem)

{-| Static elements for creating application headers.

# Models
@docs Title, Icon, IconItem, Item

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


{-| Representation of a header title.
-}
type alias Title msg =
  { action : Maybe msg
  , text : String
  }


{-| Representation of a header icon.
-}
type alias Icon msg =
  { action : Maybe msg
  , glyph : String
  , size : Float
  }


{-| Representation of a header icon item.
-}
type alias IconItem msg =
  { action : Maybe msg
  , glyph : String
  , text : String
  , side : String
  }


{-| Representation of a header item.
-}
type alias Item msg =
  Title msg


{-| Renders a header element with the given children.

    Ui.Header.view
      [ Ui.Header.title { text = "Yo!", action = Nothing } ]
-}
view : List (Html.Html msg) -> Html.Html msg
view children =
  node "ui-header" [] children


{-| Renders a header icon element which can also trigger
an action if specified.

    Ui.Header.icon
      { glyph = "social-github"
      , action = Just OpenGithub
      }
-}
icon : Icon msg -> Html.Html msg
icon model =
  node "ui-header-icon"
    ((Ui.iconAttributes model.glyph True [])
      ++ (itemAttributes model)
      ++ [ style [ ( "font-size", (toString model.size) ++ "px" ) ] ]
    )
    [ Ripple.view ]


{-| Renders a header title element which can also trigger
an action if specified.

    Ui.Header.title
      { text = "Elm-UI Rocks!"
      , action = Just Home
      }
-}
title : Title msg -> Html.Html msg
title model =
  node "ui-header-title"
    (itemAttributes model)
    [ node "div" [] [ text model.text ]
    , Ripple.view
    ]


{-| Renders a header separator element.

    Ui.Header.separator
-}
separator : Html.Html msg
separator =
  node "ui-header-separator" [] []


{-| Renders a header navigation item which can also trigger
an action if specified.

    Ui.Header.item
      { text = "Github",
      , action = Just OpenGithub
      }
-}
item : Item msg -> Html.Html msg
item model =
  node "ui-header-item"
    (itemAttributes model)
    [ text model.text
    , Ripple.view
    ]


{-| Renders an header navigation item with an icon which can also trigger
an action if specified.

    Ui.Header.iconItem
      { text = "Github"
      , action = Just OpenGithub
      , glyph = "social-github"
      , side = "left"
      }
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
