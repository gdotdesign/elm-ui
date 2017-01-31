module Ui.DropdownMenu exposing
  (Model, ViewModel, Msg, init, subscriptions, update, view, item)

{-| Dropdown menu that is always visible on the screen:
  - It opens on the click of the opener element
  - It interfaces with Ui.Helpers.Dropdown DSLs

# Model
@docs Model, Msg, init, subscriptions, update

# View
@docs ViewModel, view, item
-}

import Html.Events exposing (on)
import Html exposing (node)
import Html.Lazy

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui.Native.Uid as Uid

import Ui.Styles.DropdownMenu exposing (defaultStyle)
import Ui.Styles

import Json.Decode as Json
import Mouse
import DOM

{-| Representation of a dropdown menu:
  - **uid** - The unique identifier for a menu
  - **dropdown** - The model of the dropdown
-}
type alias Model =
  { dropdown : Dropdown
  , uid : String
  }


{-| The view model for a dropdown menu.
-}
type alias ViewModel msg =
  { items : List (Html.Html msg)
  , element : Html.Html msg
  , address : Msg -> msg
  }


{-| Messages that a dropdown menu can receive.
-}
type Msg
  = Dropdown Dropdown.Msg
  | Toggle Mouse.Position


{-| Initializes a dropdown menu.

    dropdownMenu = Ui.DropdownMenu.init ()
-}
init : () -> Model
init _ =
  { dropdown = Dropdown.init
  , uid = Uid.uid ()
  }
    |> Dropdown.offset 5


{-| Subscriptions for a dropdown menu.

    subscriptions =
      Sub.map DropdownMenu (Ui.DropdownMenu.subscriptions dropdownMenu)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)


{-| Updates a dropdown menu.

    ( updatedDropdownMenu, cmd ) = Ui.DropdownMenu.update msg dropdownMenu
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Dropdown msg ->
      Dropdown.update msg model

    Toggle position ->
      let
        isOver =
          DOM.isOver
            ((DOM.idSelector model.uid) ++ " ui-dropdown-panel")
            { top = toFloat position.y, left = toFloat position.x }
            |> Result.withDefault False
      in
        if isOver then
          model
        else
          Dropdown.toggle model


{-| Renders a dropdown menu.

    Ui.DropdownMenu.view
      { element : openerElement
      , address : address
      , items : items
      }
      dropdownMenu
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a dropdown menu

    Ui.DropdownMenu.render
      { element : openerElement
      , address : address
      , items : items
      }
      dropdownMenu
-}
render : ViewModel msg -> Model -> Html.Html msg
render viewModel model =
  Dropdown.view
    { attributes =
      [ on "click" (Json.map (Toggle >> viewModel.address) Mouse.position)
      ]
      |> (++) (Ui.Styles.apply defaultStyle)
    , address = viewModel.address << Dropdown
    , children = [ viewModel.element ]
    , contents = viewModel.items
    , tag = "ui-dropdown-menu"
    } model


{-| Renders a dropdown item.

    Ui.DopdownMenu.item attributes children
-}
item : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
item attributes children =
  node "ui-dropdown-menu-item" attributes children
