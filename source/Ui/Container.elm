module Ui.Container exposing
  ( Model, view, row, rowEnd, rowCenter, rowStart, column, columnStart
  , columnEnd, columnCenter, render) -- where

{-| Flexbox container component.

# Model
@docs Model

# View
@docs view, render

# Row
@docs row, rowStart, rowEnd, rowCenter

# Column
@docs column, columnStart, columnEnd, columnCenter
-}
import Html.Attributes exposing (classList, style)
import Html exposing (node)

{-| Representation of a container. -}
type alias Model =
  { direction : String
  , align : String
  , compact : Bool
  }

-- Options for row
rowOptions : Model
rowOptions =
  { direction = "row"
  , align = "stretch"
  , compact = False
  }

-- Options for column
columnOptions : Model
columnOptions =
  { direction = "column"
  , align = "stretch"
  , compact = False
  }

{-| Renders a container. -}
view : Model -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
view model attributes children =
  render model attributes children

{-| Renders a container as a row. -}
row : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
row attributes children =
  render rowOptions attributes children

{-| Renders a container as a row with content aligned to start. -}
rowStart : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
rowStart attributes children =
  render { rowOptions | align = "start" } attributes children

{-| Renders a container as a row with content aligned to center. -}
rowCenter : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
rowCenter attributes children =
  render { rowOptions | align = "center" } attributes children

{-| Renders a container as a row with content aligned to end. -}
rowEnd : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
rowEnd attributes children =
  render { rowOptions | align = "end" } attributes children

{-| Renders a container as a column. -}
column : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
column attributes children =
  render columnOptions attributes children

{-| Renders a container as a column with content aligned to start. -}
columnStart : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
columnStart attributes children =
  render { columnOptions | align = "start" } attributes children

{-| Renders a container as a column with content aligned to center. -}
columnCenter : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
columnCenter attributes children =
  render { columnOptions | align = "center" } attributes children

{-| Renders a container as a column with content aligned to end. -}
columnEnd : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
columnEnd attributes children =
  render { columnOptions | align = "end" } attributes children

{-| Renders a container. -}
render : Model -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
render model attributes children =
  node "ui-container" ([classes model] ++ attributes) children

-- Returns classes for a container
classes : Model -> Html.Attribute msg
classes model =
  classList [
    ("direction-" ++ model.direction, True),
    ("align-" ++ model.align, True),
    ("compact", model.compact)
  ]
