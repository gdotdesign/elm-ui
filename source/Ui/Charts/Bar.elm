module Ui.Charts.Bar (Model, Item, view) where

{-| Bar chart component.

# Model
@docs Item, Model

# View
@docs view
-}
import Html.Attributes exposing (style, title)
import Html exposing (node, text)

{-| Represents a bar in a bar chart. -}
type alias Item =
  { label : String
  , value : Float
  }

{-| Represents a bar chart. -}
type alias Model =
  { items : List Item
  , prefix : String
  , affix : String
  }

{-| Renders a bar chart. -}
view : Signal.Address a -> Model -> Html.Html
view address model =
  node
    "ui-barchart"
    []
    (List.map (\item -> renderBar item model) model.items)

{- Returns the maximum value from a bar chart. -}
maxValue : Model -> Float
maxValue model =
  List.map .value model.items
    |> List.maximum
    |> Maybe.withDefault 0

{- Renders a bar. -}
renderBar : Item -> Model -> Html.Html
renderBar item model =
  let
    label =
      (model.prefix ++ " ") ++
        (toString item.value) ++
        (" " ++ model.affix)
    percent =
      item.value / (maxValue model) * 100
        |> clamp 0 100
        |> toString
  in
    node "ui-barchart-bar" [title item.label]
      [ node "ui-barchart-bar-inner" [style [("height", percent ++ "%")]]
        [text label]
      ]
