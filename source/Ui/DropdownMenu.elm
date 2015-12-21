module Ui.DropdownMenu where

import Html.Attributes exposing (style, classList)
import Html.Events exposing (onWithOptions)
import Html.Extra exposing (onStopNothing)
import Html exposing (node)
import Json.Decode as Json exposing ((:=))

import Debug exposing (log)

type alias Model =
  { top : Float
  , left : Float
  , open : Bool
  }

type Action = Open BothDimensions

init =
  { top = 0
  , left = 0
  , open = False
  }

updatePosition : BothDimensions -> Model -> Model
updatePosition {parent,dropdown} model =
  let
    top =
      parent.top + parent.height + 5
    left =
      parent.left
  in
    { model | top = top, left = left }

view address element children model =
  node "ui-dropdown-menu"
    [ openHandler "mouseup" address Open
    ]
    [ element
    , node "ui-dropdown-menu-items"
      [ onStopNothing "mouseup"
      , onStopNothing "mousedown"
      , classList [("open", model.open)]
      , style [ ("top", (toString model.top) ++ "px")
              , ("left", (toString model.left) ++ "px")
              ]
      ]
      children
    ]

toggle model =
  { model | open = not model.open }

close model =
  { model | open = False }

handleClick pressed model =
  if not pressed then
    { model | open = False }
  else
    model

update action model =
  case (log "a" action) of
    Open dimensions ->
      updatePosition dimensions model
        |> toggle

type alias WindowDimensions =
  { width : Float
  , height : Float
  }

type alias BothDimensions =
  { parent : Html.Extra.Dimensions
  , dropdown : Html.Extra.Dimensions
  , window : WindowDimensions
  }

dimensionsDecoder : Json.Decoder BothDimensions
dimensionsDecoder =
  Json.object3
    BothDimensions
    (Json.at ["target", "dropdownMenu", "element", "dimensions"] Html.Extra.dimensionsDecoder)
    (Json.at ["target", "dropdownMenu", "dropdown", "dimensions"] Html.Extra.dimensionsDecoder)
    (Json.at ["target", "ownerDocument", "defaultView"] windowDimensionsDecoder)

windowDimensionsDecoder =
  Json.object2 WindowDimensions
    ("innerWidth" := Json.float)
    ("innerHeight" := Json.float)

openHandler event address action =
  onWithOptions
    event
    Html.Extra.stopOptions
    dimensionsDecoder
    (\dimensions -> Signal.message address (action dimensions))
