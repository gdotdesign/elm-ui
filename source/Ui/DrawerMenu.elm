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
import Html.Attributes exposing (classList, style, href, class)
import Html.Events exposing (onClick)
import Html exposing (node, text, a)

import Ui.Styles.DrawerMenu exposing (defaultStyle)
import Ui.Styles

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
  { bottom : Int
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


{-| Initializes a drawer menu.

    menu =
      Ui.DrawerMenu.init
      |> Ui.DrawerMenu.side Ui.DrawerMenu.Left
      |> Ui.DrawerMenu.top 0
      |> Ui.DrawerMenu.bottom 0
-}
init : Model
init =
  { open = False
  , side = Left
  , bottom = 0
  , top = 0
  }


{-| Messages that a drawer menu can receive.
-}
type Msg
  = Close


{-| Updates a drawer menu

  updatedMenu = Ui.DrawerMenu.update msg menu
-}
update : Msg -> Model -> Model
update msg model =
  case msg of
    Close ->
      { model | open = False }


{-| Renders a drawer menu.
-}
view : ViewModel msg -> Model -> Html.Html msg
view { address, contents } model =
  node "ui-drawer-menu"
    ( [ Ui.Styles.apply defaultStyle
      , Ui.attributeList [ ("open", model.open) ]
      ]
      |> List.concat
    )
    [ node "ui-drawer-menu-backdrop" [ onClick (address Close) ] []
    , node "ui-drawer-menu-main" []
      [ node "ui-drawer-menu-contents" [] contents
      , node "ui-drawer-menu-close" [ onClick (address Close) ] [ Ui.Icons.close [] ]
      ]
    ]


item : Ui.Link.Model msg -> Html.Html msg -> Html.Html msg
item ({ target, url, msg, contents } as link) icon =
  node "ui-drawer-menu-item" []
    [ Ui.Link.view
      { link | contents =
        [ node "ui-drawer-menu-item-contents" [] contents
        , node "ui-drawer-menu-item-icon" [] [ icon ]
        ]
      }
    ]



open : Model -> Model
open model =
  { model | open = True }
