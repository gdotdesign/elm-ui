module Ui.ButtonGroup (Model, view, init) where

{-| Groups a series of buttons together.

# Model
@docs Model, init

# View
@docs view
-}
import Signal exposing (forwardTo)

import Html.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ui.Button

{-| Representation of a button group:
  - **disabled** - Whether or not the button group is disabled
  - **items** - The label and action for each button
  - **kind** - The type of the buttons
  - **size** - The size of the buttons
-}
type alias Model a =
  { items : List (String, a)
  , disabled : Bool
  , kind : String
  , size : String
  }

{-| Initializes a button group with the given data.

    ButtonGroup.init [ ("Label", Action1)
                     , ("Label2", Action2)
                     ]
-}
init : List (String, a) -> Model a
init items =
  { disabled = False
  , items = items
  , kind = "primary"
  , size = "medium"
  }

{-| Renders a button group. -}
view : Signal.Address a -> Model a -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render intrenal
render : Signal.Address a -> Model a -> Html.Html
render address model =
  node "ui-button-group" []
    (List.map (renderButton address model) model.items)

-- Renders a button
renderButton : Signal.Address a -> Model a -> (String, a) -> Html.Html
renderButton address model (label, action) =
  Ui.Button.view
    address
    action
    { disabled = model.disabled
    , kind = model.kind
    , size = model.size
    , text = label
    }
