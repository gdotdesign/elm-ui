module Ui.Helpers.Dropdown where

{-| Dropdown for other components.

# View
@docs view

# Functions
@docs open, close
-}
import Html.Extra exposing (onStopNothing)
import Html exposing (node)

{-| Renders a dropdown. -}
view : List Html.Attribute -> List Html.Html -> Html.Html
view attributes children =
  node "ui-dropdown"
    ([onStopNothing "mousedown"] ++ attributes)
    children

{-| Opens a component. -}
open : { a | open : Bool } -> { a | open : Bool }
open model =
  { model | open = True }

{-| Closes a component. -}
close : { a | open : Bool } -> { a | open : Bool }
close model =
  { model | open = False }

