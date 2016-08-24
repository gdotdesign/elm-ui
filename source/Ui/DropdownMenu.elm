module Ui.DropdownMenu exposing
  (Model, ViewModel, Msg, Dimensions, init, subscriptions, update, view, item, close, openHandler)

{-| Dropdown menu that is always visible on the screen.

# Model
@docs Model, Msg, init, subscriptions, update

# Dimensions
@docs Dimensions, openHandler

# View
@docs ViewModel, view, item

# Functions
@docs close
-}

import Html.Attributes exposing (style, classList)
import Html.Events exposing (onWithOptions)
import Html.Events.Extra exposing (onStop)
import Html.Events.Geometry as Geometry
import Html exposing (node)
import Html.Lazy

import Json.Decode as Json
import Mouse

import Ui.Native.Scrolls as Scrolls
import Ui.Native.Dom as Dom


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
  { offsetLeft : Float
  , offsetTop : Float
  , left : Float
  , top : Float
  , open : Bool
  , favoredSides :
      { horizontal : String
      , vertical : String
      }
  }


{-| The view model for a dropdown menu.
-}
type alias ViewModel msg =
  { element : Html.Html msg
  , items : List (Html.Html msg)
  }


{-| Representation of dimensions for a dropdown menu.
-}
type alias Dimensions =
  { dropdown : Geometry.ElementDimensions
  , parent : Geometry.ElementDimensions
  , window : Geometry.WindowSize
  }


{-| Messages that a dropdown menu can receive.
-}
type Msg
  = Toggle Dimensions
  | Click Bool
  | NoOp


{-| Initializes a dropdown menu.

    dropdownMenu = Ui.DropdownMenu.init
-}
init : Model
init =
  { offsetLeft = 0
  , offsetTop = 5
  , open = False
  , left = 0
  , top = 0
  , favoredSides =
      { horizontal = "left"
      , vertical = "bottom"
      }
  }


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
  if model.open then
    Sub.batch
      [ Mouse.downs (Click << (\_ -> False))
      , Scrolls.scrolls (Click False)
      ]
  else
    Sub.none


{-| Updates a dropdown menu.

    Ui.DropdownMenu.update msg dropdownMenu
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Toggle dimensions ->
      open dimensions model

    NoOp ->
      model

    Click pressed ->
      if not pressed then
        { model | open = False }
      else
        model


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
  node
    "ui-dropdown-menu"
    [ openHandler
        "ui-dropdown-menu"
        "ui-dropdown-menu-items"
        "mouseup"
        (address << Toggle)
    ]
    [ viewModel.element
    , node
        "ui-dropdown-menu-items"
        [ onStop "mousedown" (address NoOp)
        , classList [ ( "open", model.open ) ]
        , style
            [ ( "top", (toString model.top) ++ "px" )
            , ( "left", (toString model.left) ++ "px" )
            ]
        ]
        viewModel.items
    ]


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
  { model | open = False }


{-| Decodes dimensions.
-}
decodeDimensions : String -> String -> Json.Decoder Dimensions
decodeDimensions parent dropdown =
  Json.object3
    Dimensions
    (Json.at [ "target" ] (Dom.withClosest parent (Dom.withSelector dropdown Geometry.decodeElementDimensions)))
    (Json.at [ "target" ] (Dom.withClosest parent (Dom.withSelector "*:first-child" Geometry.decodeElementDimensions)))
    Geometry.decodeWindowSize


{-| Open event handler.
-}
openHandler : String -> String -> String -> (Dimensions -> msg) -> Html.Attribute msg
openHandler parent dropdown event msg =
  onWithOptions
    event
    Html.Events.defaultOptions
    (Json.map msg (decodeDimensions parent dropdown))


{-| Updates the position of a dropdown form the given dimensions.
-}
open : Dimensions -> Model -> Model
open { parent, dropdown, window } model =
  let
    topSpace =
      parent.top - dropdown.height - model.offsetTop

    topPosition =
      topSpace

    bottomSpace =
      window.height - (parent.bottom + dropdown.height + model.offsetTop)

    bottomPosition =
      parent.bottom + model.offsetTop

    leftSpace =
      parent.left + dropdown.width + model.offsetLeft

    leftPosition =
      parent.left + model.offsetLeft

    rightSpace =
      parent.right - dropdown.width - model.offsetLeft

    rightPosition =
      rightSpace

    top =
      if model.favoredSides.vertical == "top" then
        if topSpace > 0 then
          topPosition
        else
          bottomPosition
      else if bottomSpace > 0 then
        bottomPosition
      else
        topPosition

    left =
      if model.favoredSides.horizontal == "right" then
        if rightSpace > 0 then
          rightPosition
        else
          leftPosition
      else if leftSpace < window.width then
        leftPosition
      else
        rightPosition
  in
    { model | top = top, left = left, open = True }
