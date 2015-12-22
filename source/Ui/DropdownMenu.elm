module Ui.DropdownMenu
  (Model, Action, init, update, view, item, handleClick, close) where

{-| Dropdown menu that is allways visible on the screen.

# Model
@docs Model, Action, init, update

# View
@docs view, item

# Functions
@docs handleClick, close
-}
import Html.Attributes exposing (style, classList)
import Html.Events exposing (onWithOptions)
import Html.Extra exposing (onStopNothing, WindowDimensions, windowDimensionsDecoder)
import Html exposing (node)
import Json.Decode as Json exposing ((:=))

import Debug exposing (log)

{-| Represents a dropdown menu. -}
type alias Model =
  { top : Float
  , left : Float
  , open : Bool
  , offsetX : Float
  , offsetY : Float
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
  { top = 0
  , left = 0
  , open = False
  , offsetX = 0
  , offsetY = 5
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
    [ openHandler "mouseup" address Toggle
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
item : List Html.Html -> Html.Html
item children =
  node "ui-dropdown-menu-item" [] children

{-| Updates a dropdown menu. -}
update: Action -> Model -> Model
update action model =
  case (log "a" action) of
    Toggle dimensions ->
      updatePosition dimensions model
        |> toggle

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

-- Represents dimensions of the dropdown and window.
type alias Dimensions =
  { parent : Html.Extra.Dimensions
  , dropdown : Html.Extra.Dimensions
  , window : WindowDimensions
  }

-- Toggles a dropdown menu
toggle : Model -> Model
toggle model =
  { model | open = not model.open }

-- Decodes dimensions
dimensionsDecoder : Json.Decoder Dimensions
dimensionsDecoder =
  Json.object3
    Dimensions
    (Json.at [ "target", "dropdownMenu"
             , "element", "dimensions"] Html.Extra.dimensionsDecoder)
    (Json.at [ "target", "dropdownMenu"
             , "dropdown", "dimensions"] Html.Extra.dimensionsDecoder)
    windowDimensionsDecoder

-- Open event handler
openHandler : String -> Signal.Address Action ->
              (Dimensions -> Action) -> Html.Attribute
openHandler event address action =
  onWithOptions
    event
    Html.Extra.stopOptions
    dimensionsDecoder
    (\dimensions -> Signal.message address (action dimensions))

-- Updates the position of a dropdown form the given dimensions.
updatePosition : Dimensions -> Model -> Model
updatePosition {parent,dropdown,window} model =
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
    { model | top = top, left = left }
