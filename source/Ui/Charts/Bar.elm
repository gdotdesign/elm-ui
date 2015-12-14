module Ui.Charts.Bar where

import Html.Attributes exposing (style, title)
import Html exposing (node, text)

type alias Item =
  { label : String
  , value : Float
  }

type alias Model =
  { items : List Item
  , affix : String
  , prefix : String
  }

maxValue model =
  List.map .value model.items
    |> List.maximum
    |> Maybe.withDefault 0

view address model =
  node "ui-barchart" [] (List.map (\item -> renderBar item model) model.items)

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
