module Ui.ButtonGroup exposing (Model, init, view, render)

{-| Groups a series of buttons together.

# Model
@docs Model, init

# View
@docs view, render
-}

-- where

import Html.Events.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ui.Button


{-| Representation of a button group:
  - **disabled** - Whether or not the button group is disabled
  - **items** - The label and action for each button
  - **kind** - The type of the buttons
  - **size** - The size of the buttons
-}
type alias Model msg =
  { items : List ( String, msg )
  , disabled : Bool
  , kind : String
  , size : String
  }


{-| Initializes a button group with the given data.

    buttonGroup = Ui.ButtonGroup.init [ ("Download", Download)
                                      , ("Export", Export)
                                      ]
-}
init : List ( String, msg ) -> Model msg
init items =
  { disabled = False
  , items = items
  , kind = "primary"
  , size = "medium"
  }


{-| Lazily renders a button group.

    Ui.ButtonGroup.view buttonGroup
-}
view : Model msg -> Html.Html msg
view model =
  Html.Lazy.lazy render model



{-| Renders a button group.

    Ui.ButtonGroup.render buttonGroup
-}
render : Model msg -> Html.Html msg
render model =
  node
    "ui-button-group"
    []
    (List.map (renderButton model) model.items)



{-| Renders a button for the button group.
-}
renderButton : Model msg -> ( String, msg ) -> Html.Html msg
renderButton model ( label, action ) =
  Ui.Button.view
    action
    { disabled = model.disabled
    , kind = model.kind
    , size = model.size
    , text = label
    }
