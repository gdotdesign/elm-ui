module Ui.DropdownMenu exposing
  (Model, ViewModel, Msg, init, subscriptions, update, view, item, close)

{-| Dropdown menu that is always visible on the screen.

# Model
@docs Model, Msg, init, subscriptions, update

# View
@docs ViewModel, view, item

# Functions
@docs close
-}

import Html.Attributes exposing (style, classList, id)
import Html.Events exposing (on)
import Html exposing (node)
import Html.Lazy

import Json.Decode as Json
import Mouse

import Ui.Native.Scrolls as Scrolls
import Ui.Native.Uid as Uid

import Ui.Helpers.Dropdown_ as DD

import Window

import DOM.Window
import DOM

{-| Representation of a dropdown menu:
  - **offsetLeft** - The x-axis offset for the dropdown
  - **offsetTop** - The y-axis offset for the dropdown
  - **left** - The left position of the dropdown
  - **top** - The top position of the dropdown
  - **open** - Whether or not the dropdown is open
  - **favoredSides** - The sides to open the dropdown when there is space
    - **horizontal** - Either "left" or "right"
    - **vertical** - Either "top" or "bottom"
-}
type alias Model =
  { uid : String
  , dropdown : DD.Dropdown
  }


{-| The view model for a dropdown menu.
-}
type alias ViewModel msg =
  { element : Html.Html msg
  , items : List (Html.Html msg)
  }


{-| Messages that a dropdown menu can receive.
-}
type Msg
  = Dropdown DD.Msg


{-| Initializes a dropdown menu.

    dropdownMenu = Ui.DropdownMenu.init ()
-}
init : () -> Model
init _ =
  { uid = Uid.uid ()
  , dropdown =
    DD.init
  }
    |> DD.offset 5


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
  Sub.map Dropdown (DD.subscriptions model)


{-| Updates a dropdown menu.

    Ui.DropdownMenu.update msg dropdownMenu
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Dropdown msg ->
      DD.update msg model

{-| Renders a dropdown menu.

    Ui.DropdownMenu.view
      address
      { element: triggerElement, items: items }
      dropdownMenu
-}
view : ViewModel msg -> (Msg -> msg) -> Model -> Html.Html msg
view viewModel address model =
  Html.Lazy.lazy3 render viewModel address model


{-| Renders a dropdown menu
-}
render : ViewModel msg -> (Msg -> msg) -> Model -> Html.Html msg
render viewModel address model =
  DD.view
  { elements = [viewModel.element]
  , attributes = []
  , tag = "ui-dropdown-menu"
  , dropdownTag = "ui-dropdown-menu-items"
  , address = address << Dropdown
  , items = viewModel.items
  } model


{-| Renders a dropdown item.

    Ui.DopdownMenu.item attributes children
-}
item : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
item attributes children =
  node "ui-dropdown-menu-item" attributes children


{-| Closes a dropdown menu.

    Ui.DropdownMenu.close dropdownMenu
-}
close : Model -> Model
close model =
  DD.close model
