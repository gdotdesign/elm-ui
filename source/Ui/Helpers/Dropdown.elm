module Ui.Helpers.Dropdown exposing (..)

-- where

{-| Dropdown for other components.

# Model
@docs Dropdown

# View
@docs view

# Functions
@docs open, close, toggle, openWithDimensions, toggleWithDimensions
-}
import Html.Events.Options exposing (preventDefaultOptions)
import Html.Events.Extra exposing (onStop, keysDecoder)
import Html.Events.Geometry as Geometry exposing (decodeElementDimensions)
import Html.Events exposing (defaultOptions, onWithOptions)
import Html.Attributes exposing (classList)
import Html exposing (node)

import Debug exposing (log)

import Ui.Native.Dom as Dom

import Json.Decode as Json

type alias Dimensions =
  { dimensions : Geometry.ElementDimensions
  , dropdown : Geometry.ElementDimensions
  , window : Geometry.WindowSize
  }

{-| Decodes dimensions for a element and its dropdown. -}
decoder : Json.Decoder Dimensions
decoder =
  Json.object3 Dimensions
    (Json.at ["target"] Geometry.decodeElementDimensions)
    (Json.at ["target"] (Json.oneOf [ Dom.withClosest "ui-dropdown" decodeElementDimensions
                                    , Dom.withSelector "ui-dropdown" decodeElementDimensions
                                    ]))
    Geometry.decodeWindowSize

{-| Returns dimensions for an element and its dropdown. -}
onWithDropdownDimensions : String
                           -> (Dimensions -> msg)
                           -> Html.Attribute msg
onWithDropdownDimensions event msg =
  onWithOptions
    event
    defaultOptions
    (Json.map msg decoder)

{-| An event listener that will run the given actions on the associated keys. -}
onKeysWithDropdownDimensions : List (Int, (Dimensions -> msg)) -> Html.Attribute msg
onKeysWithDropdownDimensions mappings =
  onWithOptions
    "keydown"
    preventDefaultOptions
    (Json.andThen (keysDecoder mappings) (\msg -> Json.map msg decoder))


{-| Represents a dropdown. -}
type alias Dropdown a =
  { a | open : Bool
      , dropdownPosition : String }

{-| Renders a dropdown. -}
view : msg -> String -> List (Html.Html msg) -> (Html.Html msg)
view noop position children =
  node "ui-dropdown"
    [ onStop "mousedown" noop
    , classList [("position-" ++ position, True)]
    ]
    children

{-| Opens a component. -}
open : Dropdown a -> Dropdown a
open model =
  { model | open = True }

{-| Closes a component. -}
close : Dropdown a -> Dropdown a
close model =
  { model | open = False }

{-| Toggles a component. -}
toggle : Dropdown a -> Dropdown a
toggle model =
  { model | open = not model.open }

{-| Toggles a component. -}
toggleWithDimensions : Dimensions -> Dropdown a -> Dropdown a
toggleWithDimensions dimensions model =
  if model.open then close model
  else openWithDimensions dimensions model

{-| Opens a component. -}
openWithDimensions : Dimensions -> Dropdown a -> Dropdown a
openWithDimensions {dimensions,dropdown,window} model =
  let
    bottom = dimensions.bottom + dropdown.height
    right = dimensions.right + dropdown.width
    topPosition = if bottom < window.height then "bottom" else "top"
    leftPosition = if right < window.width then "right" else "left"
    position = topPosition ++ "-" ++ leftPosition
  in
    { model | open = True, dropdownPosition = position }
