module Ui.Container (Model, view, row, rowEnd, column) where

{-| Flexbox container component.

# Model
@docs Model

# View
@docs view, row, rowEnd, column
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

-- Options for row
rowOptions : Model
rowOptions =
  { align = "stretch"
  , direction = "row"
  , compact = False
  }

-- Options for column
columnOptions : Model
columnOptions =
  { align = "stretch"
  , direction = "column"
  , compact = False
  }

{-| Renders a container. -}
view : Model -> List Html.Attribute -> List Html.Html -> Html.Html
view model attributes children =
  Html.Lazy.lazy3 render model attributes children

{-| Renders a container as a row. -}
row : List Html.Attribute -> List Html.Html -> Html.Html
row attributes children =
  Html.Lazy.lazy3 render rowOptions attributes children

{-| Renders a container as a row with content aligned to the end. -}
rowEnd : List Html.Attribute -> List Html.Html -> Html.Html
rowEnd attributes children =
  Html.Lazy.lazy3 render { rowOptions | align = "end" } attributes children

{-| Renders a container as a column. -}
column : List Html.Attribute -> List Html.Html -> Html.Html
column attributes children =
  Html.Lazy.lazy3 render columnOptions attributes children

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
