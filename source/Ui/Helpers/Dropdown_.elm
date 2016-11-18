module Ui.Helpers.Dropdown_ exposing (..)

{-| This is a module for creating components that have a dropdown
element.

```
colorPicker =
  Ui.ColorPicker.init ()
    |> Dropdown.direction Horizontal -- open to left or right
    |> Dropdown.favoring Left -- open to left if there is space
    |> Dropdown.alignTo Top -- align it to the top of the trigger element
    |> Dropdown.offset 5
```
-}
import Html.Attributes exposing (style, classList, id, attribute)
import Html.Events exposing (on)
import Html exposing (node)

import Json.Decode as Json
import Window
import Mouse

import DOM.Window
import DOM

import Ui.Native.Scrolls as Scrolls

type Direction
  = Horizontal
  | Vertical

type Side
  = Bottom
  | Right
  | Left
  | Top

type Space
  = Positive
  | Negative

type Msg
  = Click Mouse.Position
  | Toggle Mouse.Position
  | Close

type alias ViewModel msg =
  { attributes : List (Html.Attribute msg)
  , elements : List (Html.Html msg)
  , items : List (Html.Html msg)
  , address : Msg -> msg
  , dropdownTag : String
  , tag : String
  }

type alias Dropdown =
  { direction : Direction
  , clickToggle : Bool
  , favoring : Space
  , alignTo : Space
  , offset : Float
  , left : Float
  , top : Float
  , open : Bool
  }

type alias Model a =
  { a
    | dropdown : Dropdown
    , uid : String
  }


init : Dropdown
init =
  { direction = Vertical
  , favoring = Positive
  , alignTo = Positive
  , clickToggle = True
  , open = False
  , offset = 0
  , left = 0
  , top = 0
  }

-- PUBLIC API

clickToggle : Bool -> Model a -> Model a
clickToggle value model =
  updateDropdown
    (\dropdown -> { dropdown | clickToggle = value } )
    model

direction : Direction -> Model a -> Model a
direction value model =
  updateDropdown
    (\dropdown -> { dropdown | direction = value } )
    model

alignTo : Side -> Model a -> Model a
alignTo side model =
  updateDropdown
    (\dropdown -> { dropdown | alignTo = getSpaceFromSide side } )
    model

favoring : Side -> Model a -> Model a
favoring side model =
  updateDropdown
    (\dropdown -> { dropdown | favoring = getSpaceFromSide side } )
    model

offset : Float -> Model a -> Model a
offset offset model =
  updateDropdown
    (\dropdown -> { dropdown | offset = offset } )
    model

open : Model a -> Model a
open model =
  updateDropdown
    (\dropdown -> openDropdown model.uid dropdown)
    model

close : Model a -> Model a
close model =
  updateDropdown
    (\dropdown -> { dropdown | open = False })
    model

toggle : Model a -> Model a
toggle model =
  if model.dropdown.open then
    close model
  else
    open model

subscriptions : Model a -> Sub Msg
subscriptions model =
  if model.dropdown.open then
    Sub.batch
      [ Window.resizes (\_ -> Close)
      , Scrolls.scrolls Close
      , Mouse.downs Click
      ]
  else
    Sub.none

update : Msg -> Model a -> Model a
update msg model =
  case msg of
    Toggle position ->
      if isOver (model.uid ++ "-dropdown") position then
        model
      else
        toggle model

    Click position ->
      if isOver model.uid position then
        model
      else
        close model

    Close ->
      close model

view : ViewModel msg -> Model a -> Html.Html msg
view viewModel model =
  let
    clickToggleAttr =
      if model.dropdown.clickToggle then
        [ on "click" (Json.map (viewModel.address << Toggle) Mouse.position) ]
      else
        []
  in
    node viewModel.tag
      ([ id model.uid
      , attribute "dropdown" ""
      ] ++ viewModel.attributes ++ clickToggleAttr)
      ( viewModel.elements
      ++ [ node
          viewModel.dropdownTag
          [ classList [ ( "open", model.dropdown.open ) ]
          , id (model.uid ++ "-dropdown")
          , attribute "dropdown-panel" ""
          , style
              [ ( "top", (toString model.dropdown.top) ++ "px" )
              , ( "left", (toString model.dropdown.left) ++ "px" )
              ]
          ]
          viewModel.items
      ])

-- PRIVATE API

isOver : String -> Mouse.Position -> Bool
isOver id position =
  DOM.isOver (DOM.idSelector id) { top = position.y, left = position.x }
    |> Result.withDefault False

updateDropdown : (Dropdown -> Dropdown) -> Model a -> Model a
updateDropdown function model =
  { model | dropdown = function model.dropdown }

getSpaceFromSide : Side -> Space
getSpaceFromSide side =
  case side of
    Bottom -> Positive
    Right -> Positive
    Left -> Negative
    Top -> Negative

defaultRect : DOM.Dimensions
defaultRect =
  { top = 0, left = 0, right = 0, bottom = 0, width = 0, height = 0 }

openDropdown : String -> Dropdown -> Dropdown
openDropdown uid model =
  let
    -- Get Window Positions
    window =
      { height = toFloat (DOM.Window.height ())
      , width = toFloat (DOM.Window.width ())
      }

    parent =
      DOM.getDimensionsSync (DOM.idSelector uid)
        |> Result.withDefault defaultRect

    dropdown =
      DOM.getDimensionsSync (DOM.idSelector (uid ++ "-dropdown"))
        |> Result.withDefault defaultRect
  in
    { model
    | open = True
    , left = calculateLeft window parent dropdown model
    , top = calculateTop window parent dropdown model
    }

decideSide side positiveOptimal negativeOptimal bound size =
  case side of
    Positive ->
      if (positiveOptimal + size) > bound then
        negativeOptimal
      else
        positiveOptimal
    Negative ->
      if negativeOptimal < 0 then
        positiveOptimal
      else
        negativeOptimal

favored model high low bound size =
  let
    positiveOptimal = low + model.offset
    negativeOptimal = high - size - model.offset
  in
    decideSide model.favoring positiveOptimal negativeOptimal bound size

align model high low bound size =
  let
    positiveOptimal = high
    negativeOptimal = low - size
  in
    decideSide model.alignTo positiveOptimal negativeOptimal bound size

calculateLeft window parent dropdown model =
  let
    maxiumum =
      window.width - dropdown.width

    optimal =
      case model.direction of
        Horizontal ->
          favored model parent.left parent.right window.width dropdown.width
        Vertical ->
          align model parent.left parent.right window.width dropdown.width
  in
    min maxiumum optimal

calculateTop window parent dropdown model =
  let
    maxiumum =
      window.height - dropdown.height

    optimal =
      case model.direction of
        Horizontal ->
          align model parent.top parent.bottom window.height dropdown.height
        Vertical ->
          favored model parent.top parent.bottom window.height dropdown.height
  in
    min maxiumum optimal
