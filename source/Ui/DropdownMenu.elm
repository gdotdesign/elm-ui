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

import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Lazy

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui.Native.Uid as Uid


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
  | Toggle


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

    ...
    subscriptions =
      \model ->
        Sub.map
          DropdownMenu
          (Ui.DropdownMenu.subscriptions model.dropdownMenu)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)


{-| Updates a dropdown menu.

    Ui.DropdownMenu.update msg dropdownMenu
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Dropdown msg ->
      Dropdown.update msg model

    Toggle ->
      Dropdown.toggle model


{-| Renders a dropdown menu.

    Ui.DropdownMenu.view
      { element: openerElement
      , address : address
      , items: items
      }
      dropdownMenu
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a dropdown menu
-}
render : ViewModel msg -> Model -> Html.Html msg
render viewModel model =
  Dropdown.view
    { attributes = [onClick (viewModel.address Toggle) ]
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
