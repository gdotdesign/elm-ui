module Ui.DropdownMenu where

import Html.Attributes exposing (style, classList)
import Html.Events exposing (onWithOptions)
import Html.Extra exposing (onStopNothing, WindowDimensions, windowDimensionsDecoder)
import Html exposing (node)
import Json.Decode as Json exposing ((:=))

import Debug exposing (log)

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

type Action = Toggle BothDimensions

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

updatePosition : BothDimensions -> Model -> Model
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

view address element children model =
  node "ui-dropdown-menu"
    [ openHandler "mouseup" address Toggle
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
    Toggle dimensions ->
      updatePosition dimensions model
        |> toggle

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
    windowDimensionsDecoder

openHandler event address action =
  onWithOptions
    event
    Html.Extra.stopOptions
    dimensionsDecoder
    (\dimensions -> Signal.message address (action dimensions))
