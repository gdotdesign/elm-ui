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

import Maybe.Extra exposing (isJust)

import Ui.Helpers.Ripple as Ripple
import Ui


{-| Representation of a header title.
-}
type alias Title msg =
  { link : Maybe String
  , action : Maybe msg
  , target : String
  , text : String
  }


{-| Representation of a header icon.
-}
type alias Icon msg =
  { link : Maybe String
  , action : Maybe msg
  , target : String
  , glyph : String
  , size : Float
  }


{-| Representation of a header icon item.
-}
type alias IconItem msg =
  { link : Maybe String
  , action : Maybe msg
  , target : String
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
      [ Ui.Header.title
        { action = Nothing
        , target = "_self"
        , link = Nothing
        , text = "Yo!"
        }
      ]
-}
view : List (Html.Html msg) -> Html.Html msg
view children =
  node "ui-header" [] children


{-| Renders a header icon element which can:
- link to an other page if specified
- trigger an action if specified

    Ui.Header.icon
      { action = Just OpenGithub
      , glyph = "social-github"
      , target = "_blank"
      , link = Nothing
      , size = 30
      }
-}
icon : Icon msg -> Html.Html msg
icon model =
  node "ui-header-icon"
    ((itemAttributes model)
      ++ [ style [ ( "font-size", (toString model.size) ++ "px" ) ] ]
    )
    [ Ui.link model.action model.link model.target
      [ Ripple.view
      , Ui.icon model.glyph False []
      ]
    ]


{-| Renders a header title element which can:
- link to an other page if specified
- trigger an action if specified

    Ui.Header.title
      { text = "Elm-UI Rocks!"
      , action = Just Home
      , target = "_self"
      , link = Nothing
      }
-}
title : Title msg -> Html.Html msg
title model =
  node "ui-header-title"
    (itemAttributes model)
    [ Ui.link model.action model.link model.target
      [ node "span" [] [ text model.text ]
      , Ripple.view
      ]
    ]


{-| Renders a header separator element.

    Ui.Header.separator
-}
separator : Html.Html msg
separator =
  node "ui-header-separator" [] []


{-| Renders a header navigation item which can:
- link to an other page if specified
- trigger an action if specified

    Ui.Header.item
      { link = Just "https://www.github.com"
      , target = "_blank"
      , action = Nothing
      , text = "Github"
      }
-}
item : Item msg -> Html.Html msg
item model =
  node "ui-header-item"
    (itemAttributes model)
    [ Ui.link model.action model.link model.target
      [ node "span" [] [ text model.text ]
      , Ripple.view
      ]
    ]


{-| Renders an header navigation item with an icon item which can:
- link to an other page if specified
- trigger an action if specified

    Ui.Header.iconItem
      { action = Just OpenGithub
      , glyph = "social-github"
      , target = "_self"
      , text = "Github"
      , link = Nothing
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
      [ Ui.link model.action model.link model.target (Ripple.view :: children) ]


{-| Returns attributes for an item.
-}
itemAttributes : { model | action : Maybe msg, link : Maybe String } -> List (Html.Attribute msg)
itemAttributes { action, link } =
  if isJust action || isJust link then
    [ attribute "interactive" ""]
  else
    []
