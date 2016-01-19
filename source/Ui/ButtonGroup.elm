module Ui.ButtonGroup where

import Signal exposing (forwardTo)

import Html exposing (node)
import Html.Lazy

import Ui.Button

type alias Item a =
  { label : String
  , action : a
  }

type alias Model a =
  { items : List (Item a)
  , disabled : Bool
  , kind : String
  , size : String
  }

init : List (Item a) -> String -> Model a
init items value =
  { disabled = False
  , items = items
  , kind = "primary"
  , size = "medium"
  }

view : Signal.Address a -> Model a -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

render : Signal.Address a -> Model a -> Html.Html
render address model =
  node "ui-button-group" []
    (List.map (renderButton address model) model.items)

renderButton : Signal.Address a -> Model a -> Item a -> Html.Html
renderButton address model {label,action} =
  Ui.Button.view
    address
    action
    { disabled = model.disabled
    , kind = model.kind
    , size = model.size
    , text = label
    }
