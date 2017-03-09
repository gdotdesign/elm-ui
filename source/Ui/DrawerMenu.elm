module Ui.DrawerMenu exposing (..)

{-| This module provides a component for creating a menu either on the left
or the right side of the window that is hidden by default.

# Model
@docs Model, Msg, init, update

# View
@docs view

# Functions
@docs toggle
-}
import Html.Events.Extra exposing (onTransitionEnd)
import Html.Attributes exposing (property, style)
import Html.Events exposing (onClick)
import Html exposing (node, text, a)

import Ui.Styles.DrawerMenu exposing (defaultStyle)
import Ui.Styles

import Json.Decode as Json
import Json.Encode as JE

import Ui.Icons
import Ui.Link
import Ui

{-| Represents a side.
-}
type Side
  = Right
  | Left


{-| Representation of a drawer menu:
  - **visible** - Whether or not the drawer menu is open
-}
type alias Model =
  { contentsShown : Bool
  , bottom : Int
  , open : Bool
  , side : Side
  , top : Int
  }


{-| Representation of the view model of a drawer menu.
  - **address** - The address for the messages
  - **contents** - The contents to displa
-}
type alias ViewModel msg =
  { contents : List (Html.Html msg)
  , address : Msg -> msg
  }


{-| Representation of a link:
  - **contents** - The contents of the link, usually just text
  - **target** - The value for the target attribute
  - **url** - The value for the href attribute
  - **msg** - The message to trigger
-}
type alias Item msg =
  { contents : List (Html.Html msg)
  , icon : Maybe (Html.Html msg)
  , target : Maybe String
  , url : Maybe String
  , msg : Maybe msg
  }


{-| Initializes a drawer menu.

    menu =
      Ui.DrawerMenu.init
      |> Ui.DrawerMenu.side Ui.DrawerMenu.Left
      |> Ui.DrawerMenu.top 0
      |> Ui.DrawerMenu.bottom 0
-}
init : Model
init =
  { contentsShown = False
  , open = False
  , side = Left
  , bottom = 0
  , top = 0
  }


{-| Messages that a drawer menu can receive.
-}
type Msg
  = HideContents
  | Close


{-| Updates a drawer menu

  updatedMenu = Ui.DrawerMenu.update msg menu
-}
update : Msg -> Model -> Model
update msg model =
  case msg of
    Close ->
      close model

    HideContents ->
      { model | contentsShown = False }


{-| Renders a drawer menu.
-}
view : ViewModel msg -> Model -> Html.Html msg
view { address, contents } model =
  let
    transitionEvent =
      if not model.open then
        let
          decoder =
            Json.at
              [ "target", "_menu" ]
              (Json.succeed (address HideContents))
        in
          [ onTransitionEnd decoder
          , property "_menu" (JE.string "0")
          ]
      else
        []

    mainContents =
      if model.contentsShown then
        contents
      else
        []
  in
    node "ui-drawer-menu"
      ( [ Ui.Styles.apply defaultStyle
        , Ui.attributeList [ ( "open", model.open ) ]
        , transitionEvent
        ]
        |> List.concat
      )
      [ node "ui-drawer-menu-backdrop" [ onClick (address Close) ] []
      , node "ui-drawer-menu-main" [] mainContents
      ]

title : String -> Html.Html msg
title value =
  node "ui-drawer-menu-title" [] [ text value ]

devider : Html.Html msg
devider =
  node "ui-drawer-menu-devider" [] []

item : Item msg -> Html.Html msg
item { target, url, msg, contents, icon }  =
  let
    iconNode =
      case icon of
        Just svg ->
          node "ui-drawer-menu-item-icon" [] [ svg ]

        Nothing ->
          text ""
  in
    node "ui-drawer-menu-item" []
      [ Ui.Link.view
        { target = target
        , url = url
        , msg = msg
        , contents =
          [ iconNode
          , node "ui-drawer-menu-item-contents" [] contents
          ]
        }
      ]



open : Model -> Model
open model =
  { model | open = True, contentsShown = True }

close : Model -> Model
close model =
  { model | open = False }
