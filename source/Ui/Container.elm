module Ui.Container (Model, view) where

{-| Flexbox container component.

# Model
@docs Model

# View
@docs view
-}
import Html.Attributes exposing (classList, style)
import Html exposing (node)
import Html.Lazy

{-| Representation of a container. -}
type alias Model =
  { direction : String
  , align : String
  , compact : Bool
  }

{-| Renders a container. -}
view : Model -> List Html.Attribute -> List Html.Html -> Html.Html
view model attributes children =
  Html.Lazy.lazy3 render model attributes children

-- Render internal
render : Model -> List Html.Attribute -> List Html.Html -> Html.Html
render model attributes children =
  node "ui-container" ([classes model] ++ attributes) children

-- Returns classes for a container
classes : Model -> Html.Attribute
classes model =
  classList [
    ("align-" ++ model.align, True),
    ("direction-" ++ model.direction, True),
    ("compact", model.compact)
  ]
