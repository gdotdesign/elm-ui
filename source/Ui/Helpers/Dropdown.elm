module Ui.Helpers.Dropdown exposing
  ( Direction(..), Side(..), Msg, Dropdown, Model, init, update, subscriptions
  , favoring, alignTo, offset, direction, open, close, toggle, view, render )

{-| This is a module for creating components that have a dropdown.

```
colorPicker =
  Ui.ColorPicker.init ()
    |> Dropdown.alignTo Top -- align it to the top of the trigger element
    |> Dropdown.favoring Left -- open to left if there is space
    |> Dropdown.direction Horizontal -- open to left or right
    |> Dropdown.offset 5
```

# Types
@docs Direction, Side, Msg, Dropdown

# Model
@docs Model, init, update, subscriptions

# DSL
@docs offset, direction, favoring, alignTo

# Functions
@docs open, close, toggle

# Rendering
@docs view, render

-}

import Html.Attributes exposing (style, id, attribute)
import Html exposing (node)
import Html.Lazy

import Window
import Mouse

import DOM exposing (Dimensions)
import DOM.Window

import Ui.Styles.Dropdown exposing (defaultStyle)
import Ui.Styles

import Ui.Native.Scrolls as Scrolls
import Ui

{-| Representation of the direction where the dropdown opens:
    * Horizontal - either left or right
    * Vertical - either top or bottom
-}
type Direction
  = Horizontal
  | Vertical


{-| Representation of the a side.
-}
type Side
  = Bottom
  | Right
  | Left
  | Top


{-| Representation of part of a direction similar to a Cartesian coordinate
systems.
-}
type Space
  = Positive
  | Negative


{-| Messages that a dropdown can receive.
-}
type Msg
  = Click Mouse.Position
  | Close


{-| Representation of things in the view.
-}
type alias ViewModel msg =
  { attributes : List (Html.Attribute msg)
  , children : List (Html.Html msg)
  , contents : List (Html.Html msg)
  , address : Msg -> msg
  , tag : String
  }


{-| Representation of a dropdown.
-}
type alias Dropdown =
  { direction : Direction
  , favoring : Space
  , alignTo : Space
  , offset : Float
  , left : Float
  , top : Float
  , open : Bool
  }


{-| Representation of a component which has a dropdown.
-}
type alias Model a =
  { a
    | dropdown : Dropdown
    , uid : String
  }


{-| Initializes a dropdown.
-}
init : Dropdown
init =
  { direction = Vertical
  , favoring = Positive
  , alignTo = Positive
  , open = False
  , offset = 0
  , left = 0
  , top = 0
  }


{-| Sets the direction of a dropdown, this property indicates where the dropdown
will open.
-}
direction : Direction -> Model a -> Model a
direction value model =
  updateDropdown
    (\dropdown -> { dropdown | direction = value })
    model


{-| Sets where to align a dropdown when it's open. For example if a dropdown
opens horizontally to either to the left or right, then it can be aligned to
either the top or the bottom of the opening element.
-}
alignTo : Side -> Model a -> Model a
alignTo side model =
  updateDropdown
    (\dropdown -> { dropdown | alignTo = stwitchSpace (getSpaceFromSide side) })
    model


{-| Sets where to open a dropdown if there is more space.
-}
favoring : Side -> Model a -> Model a
favoring side model =
  updateDropdown
    (\dropdown -> { dropdown | favoring = getSpaceFromSide side })
    model


{-| Sets the offset of the dropdown from it's opening element.
-}
offset : Float -> Model a -> Model a
offset offset model =
  updateDropdown
    (\dropdown -> { dropdown | offset = offset })
    model


{-| Opens a dropdown.
-}
open : Model a -> Model a
open model =
  updateDropdown
    (\dropdown -> openDropdown model.uid dropdown)
    model


{-| Closes a dropdown.
-}
close : Model a -> Model a
close model =
  updateDropdown
    (\dropdown -> { dropdown | open = False })
    model


{-| Toggles a dropdown.
-}
toggle : Model a -> Model a
toggle model =
  if model.dropdown.open then
    close model
  else
    open model


{-| Subscriptions for a dropdown.
-}
subscriptions : Model a -> Sub Msg
subscriptions model =
  if model.dropdown.open then
    Sub.batch
      [ Window.resizes (always Close)
      , Scrolls.scrolls Close
      , Mouse.downs Click
      ]
  else
    Sub.none


{-| Updates a dropdown.
-}
update : Msg -> Model a -> Model a
update msg model =
  case msg of
    Click position ->
      if isOver model.uid position then
        model
      else
        close model

    Close ->
      close model


{-| Renders a dropdown lazily.
-}
view : ViewModel msg -> Model a -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a dropdown.
-}
render : ViewModel msg -> Model a -> Html.Html msg
render viewModel model =
  let
    attributes =
      [ id model.uid
      ]
        |> (++) viewModel.attributes

    dropdown =
      node "ui-dropdown-panel"
        ([ Ui.attributeList
           [ ( "open", model.dropdown.open ) ]
         , [ id (model.uid ++ "-dropdown")
           , style
               [ ( "left", (toString model.dropdown.left) ++ "px" )
               , ( "top", (toString model.dropdown.top) ++ "px" )
               ]
           ]
         , Ui.Styles.apply defaultStyle
         ] |> List.concat
        )
        viewModel.contents

    children =
      viewModel.children ++ [ dropdown ]
  in
    node viewModel.tag attributes children


{-| Tests if the given position is above the given selector.
-}
isOver : String -> Mouse.Position -> Bool
isOver id position =
  DOM.isOver (DOM.idSelector id)
    { top = toFloat position.y, left = toFloat position.x }
    |> Result.withDefault False


{-| Updates a dropdown of a model.
-}
updateDropdown : (Dropdown -> Dropdown) -> Model a -> Model a
updateDropdown function model =
  { model | dropdown = function model.dropdown }


{-| Converts `Side` to `Space`.
-}
getSpaceFromSide : Side -> Space
getSpaceFromSide side =
  case side of
    Bottom ->
      Positive

    Right ->
      Positive

    Left ->
      Negative

    Top ->
      Negative


{-| Gets the other `Space` from a `Space`.
-}
stwitchSpace : Space -> Space
stwitchSpace space =
  case space of
    Positive ->
      Negative

    Negative ->
      Positive


{-| Returns an empty rect (used as fallback).
-}
defaultRect : DOM.Dimensions
defaultRect =
  { top = 0, left = 0, right = 0, bottom = 0, width = 0, height = 0 }


{-| Opens a dropdown with the given ID and dropdown model.
-}
openDropdown : String -> Dropdown -> Dropdown
openDropdown uid model =
  let
    -- Get Window positions
    window =
      { height = DOM.Window.height ()
      , width = DOM.Window.width ()
      }

    -- Get parent dimensions
    parent =
      DOM.getDimensionsSync (DOM.idSelector uid)
        |> Result.withDefault defaultRect

    -- Get dropdown dimensions
    dropdown =
      DOM.getDimensionsSync (DOM.idSelector (uid ++ "-dropdown"))
        |> Result.withDefault defaultRect
  in
    { model
      | left = calculateLeft window parent dropdown model
      , top = calculateTop window parent dropdown model
      , open = True
    }


{-| Decides position from the given arguments and `Space`.
-}
decideSide : Space -> Float -> Float -> Float -> Float -> Float
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


{-| Decides the favored size from the given arguments.
-}
favored : Dropdown -> Float -> Float -> Float -> Float -> Float
favored model high low bound size =
  let
    positiveOptimal =
      low + model.offset

    negativeOptimal =
      high - size - model.offset
  in
    decideSide model.favoring positiveOptimal negativeOptimal bound size


{-| Decides the alignment position from the given arguments.
-}
align : Dropdown -> Float -> Float -> Float -> Float -> Float
align model high low bound size =
  let
    positiveOptimal =
      high

    negativeOptimal =
      low - size
  in
    decideSide model.alignTo positiveOptimal negativeOptimal bound size


{-| Calucates the left position from the given arguments.
-}
calculateLeft : { width : Float, height : Float } -> Dimensions -> Dimensions -> Dropdown -> Float
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


{-| Calucates the top position from the given arguments.
-}
calculateTop : { width : Float, height : Float } -> Dimensions -> Dimensions -> Dropdown -> Float
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
