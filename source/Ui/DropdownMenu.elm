module Ui.DropdownMenu
  (Dimensions, Model, Action, init, update, view, item, handleClick, close
  , open, openHandler) where

{-| Dropdown menu that is always visible on the screen.

# Model
@docs Dimensions, Model, Action, init, update

# View
@docs view, item

# Functions
@docs handleClick, close, open, openHandler
-}
import Html.Extra exposing ( onStopNothing, WindowDimensions
                           , windowDimensionsDecoder)
import Html.Attributes exposing (style, classList)
import Html.Events exposing (onWithOptions)
import Html exposing (node)
import Json.Decode as Json

import Native.Browser

{-| Represents dimensions for a dropdown menu. -}
type alias Dimensions =
  { parent : Html.Extra.Dimensions
  , dropdown : Html.Extra.Dimensions
  , window : WindowDimensions
  }

{-| Represents a dropdown menu:
  - **favoredSides** - The sides to open the dropdown when there is space
    - **horizontal** - Either "left" or "right"
    - **vertical** - Either "top" or "bottom"
  - **offsetX** - The x-axis offset for the dropdown
  - **offsetY** - The y-axis offset for the dropdown
  - **open** - Whether or not the dropdown is open
  - **left** (internal) - The left position of the dropdown
  - **top** (internal) - The top position of the dropdown
-}
type alias Model =
  { offsetX : Float
  , offsetY : Float
  , left : Float
  , top : Float
  , open : Bool
  , favoredSides : { horizontal : String
                   , vertical : String
                   }
  }

{-| Actions that a dropdown menu can make. -}
type Action
  = Toggle Dimensions

{-| Initializes a dropdown. -}
init : Model
init =
  { open = False
  , offsetX = 0
  , offsetY = 5
  , left = 0
  , top = 0
  , favoredSides = { horizontal = "left"
                   , vertical = "bottom"
                   }
  }

{-| Renders a dropdown menu for the given trigger element and children.

    DropdownMenu.view address triggerElement children model
-}
view: Signal.Address Action -> Html.Html -> List Html.Html -> Model -> Html.Html
view address element children model =
  node "ui-dropdown-menu"
    [ openHandler "ui-dropdown-menu" "ui-dropdown-menu-items" "mouseup" address Toggle
    ]
    [ element
    , node "ui-dropdown-menu-items"
      [ onStopNothing "mouseup"
      , classList [("open", model.open)]
      , style [ ("top", (toString model.top) ++ "px")
              , ("left", (toString model.left) ++ "px")
              ]
      ]
      children
    ]

{-| Renders a dropdown item. -}
item : List Html.Attribute -> List Html.Html -> Html.Html
item attributes children =
  node "ui-dropdown-menu-item" attributes children

{-| Updates a dropdown menu. -}
update: Action -> Model -> Model
update action model =
  case action of
    Toggle dimensions ->
      open dimensions model

{-| Handles the click, closes the modal if not pressed. -}
handleClick : Bool -> Model -> Model
handleClick pressed model =
  if not pressed then
    { model | open = False }
  else
    model

{-| Closes a dropdown menu. -}
close : Model -> Model
close model =
  { model | open = False }

-- Decodes dimensions
dimensionsDecoder : String -> String -> Json.Decoder Dimensions
dimensionsDecoder parent dropdown =
  Json.object3
    Dimensions
    (Json.at ["target"] (Native.Browser.closest parent (Native.Browser.atElement "*:first-child" (Json.at ["dimensions"] Html.Extra.dimensionsDecoder))))
    (Json.at ["target"] (Native.Browser.closest parent (Native.Browser.atElement dropdown (Json.at ["dimensions"] Html.Extra.dimensionsDecoder))))
    windowDimensionsDecoder

{-| Open event handler. -}
openHandler : String -> String -> String -> Signal.Address a ->
              (Dimensions -> a) -> Html.Attribute
openHandler parent dropdown event address action =
  onWithOptions
    event
    Html.Events.defaultOptions
    (dimensionsDecoder parent dropdown)
    (\dimensions -> Signal.message address (action dimensions))

{-| Updates the position of a dropdown form the given dimensions. -}
open : Dimensions -> Model -> Model
open {parent,dropdown,window} model =
  let
    topSpace = parent.top - dropdown.height - model.offsetY
    topPosition = topSpace

    bottomSpace = window.height - (parent.bottom + dropdown.height + model.offsetY)
    bottomPosition = parent.bottom + model.offsetY

    leftSpace = parent.left + dropdown.width + model.offsetX
    leftPosition = parent.left + model.offsetX

    rightSpace = parent.right - dropdown.width - model.offsetX
    rightPosition = rightSpace

    top =
      if model.favoredSides.vertical == "top" then
        if topSpace > 0 then topPosition
        else bottomPosition
      else if bottomSpace > 0 then
        bottomPosition
      else
        topPosition

    left =
      if model.favoredSides.horizontal == "right" then
        if rightSpace > 0 then rightPosition
        else leftPosition
      else if leftSpace < window.width then
        leftPosition
      else
        rightPosition
  in
    { model | top = top, left = left, open = True }
