module Ui.Helpers.Dropdown where

{-| Dropdown for other components.

# Model
@docs Dropdown

# View
@docs view

# Functions
@docs open, close, toggle, openWithDimensions, toggleWithDimensions
-}
import Html.Attributes exposing (classList)
import Html.Extra exposing (onStopNothing)
import Html exposing (node)

import Debug exposing (log)

{-| Represents a dropdown. -}
type alias Dropdown a =
  { a | open : Bool
      , dropdownPosition : String }

{-| Renders a dropdown. -}
view : String -> List Html.Html -> Html.Html
view position children =
  node "ui-dropdown"
    [ onStopNothing "mousedown"
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
toggleWithDimensions : Html.Extra.DropdownDimensions -> Dropdown a -> Dropdown a
toggleWithDimensions dimensions model =
  if model.open then close model
  else openWithDimensions dimensions model

{-| Opens a component. -}
openWithDimensions : Html.Extra.DropdownDimensions -> Dropdown a -> Dropdown a
openWithDimensions {dimensions,dropdown,window} model =
  let
    bottom = dimensions.bottom + dropdown.height
    right = dimensions.right + dropdown.width
    topPosition = if bottom < window.height then "bottom" else "top"
    leftPosition = if right < window.width then "right" else "left"
    position = topPosition ++ "-" ++ leftPosition
  in
    { model | open = True, dropdownPosition = position }
