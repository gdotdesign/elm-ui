module Ui.Helpers.Dropdown exposing (..)

{-| This module provides utility functions for handing dropdowns for components.

# Model
@docs Dimensions, Dropdown

# View
@docs view

# Decoder
@docs decodeDimensions

# Event Handlers
@docs onKeysWithDimensions, onWithDimensions

# Functions
@docs open, close, toggle, openWithDimensions, toggleWithDimensions
-}

import Html.Events.Geometry as Geometry exposing (decodeElementDimensions)
import Html.Events exposing (defaultOptions, onWithOptions)
import Html.Events.Options exposing (preventDefaultOptions)
import Html.Events.Extra exposing (onStop, keysDecoder)
import Html.Attributes exposing (classList)
import Html exposing (node)

import Ui.Native.Dom as Dom

import Json.Decode as Json


{-| Representation of the dimensions of a dropdown.
-}
type alias Dimensions =
  { dimensions : Geometry.ElementDimensions
  , dropdown : Geometry.ElementDimensions
  , window : Geometry.WindowSize
  }


{-| Representation of a dropdown.
-}
type alias Dropdown a =
  { a
    | open : Bool
    , dropdownPosition : String
  }


{-| Decodes dimensions for a element and its dropdown.
-}
decodeDimensions : Json.Decoder Dimensions
decodeDimensions =
  Json.map3
    Dimensions
    (Json.at [ "target" ] decodeElementDimensions)
    (Json.at [ "target" ] (Dom.withNearest "ui-dropdown" decodeElementDimensions))
    Geometry.decodeWindowSize


{-| Captures events with the dimensions of the dropdown.
-}
onWithDimensions : String -> (Dimensions -> msg) -> Html.Attribute msg
onWithDimensions event msg =
  onWithOptions
    event
    defaultOptions
    (Json.map msg decodeDimensions)


{-| Captures keydown events with the dimensions of the dropdown which will call
the given message associated with the given key.
-}
onKeysWithDimensions : List ( Int, Dimensions -> msg ) -> Html.Attribute msg
onKeysWithDimensions mappings =
  onWithOptions
    "keydown"
    preventDefaultOptions
    (Json.andThen (\msg -> Json.map msg decodeDimensions) (keysDecoder mappings))


{-| Renders a dropdown.
-}
view : msg -> String -> List (Html.Html msg) -> Html.Html msg
view noop position children =
  node
    "ui-dropdown"
    [ onStop "mousedown" noop
    , classList [ ( "position-" ++ position, True ) ]
    ]
    children


{-| Opens a dropdown.
-}
open : Dropdown a -> Dropdown a
open model =
  { model | open = True }


{-| Closes a dropdown.
-}
close : Dropdown a -> Dropdown a
close model =
  { model | open = False }


{-| Toggles a dropdown.
-}
toggle : Dropdown a -> Dropdown a
toggle model =
  { model | open = not model.open }


{-| Toggles a dropdown positioning it based on the given dimensions.
-}
toggleWithDimensions : Dimensions -> Dropdown a -> Dropdown a
toggleWithDimensions dimensions model =
  if model.open then
    close model
  else
    openWithDimensions dimensions model


{-| Opens a dropdown positioning it based on the given dimensions.
-}
openWithDimensions : Dimensions -> Dropdown a -> Dropdown a
openWithDimensions { dimensions, dropdown, window } model =
  let
    bottom =
      dimensions.bottom + dropdown.height

    right =
      dimensions.right + dropdown.width

    topPosition =
      if bottom < window.height then
        "bottom"
      else
        "top"

    leftPosition =
      if right < window.width then
        "right"
      else
        "left"

    position =
      topPosition ++ "-" ++ leftPosition
  in
    { model | open = True, dropdownPosition = position }
