module Ui.ButtonGroup exposing (Model, model, view, render)

{-| Groups a series of buttons together.

# Model
@docs Model, model

# View
@docs view, render
-}

import Html exposing (node)
import Html.Lazy

import Ui.Styles.ButtonGroup exposing (defaultStyle)
import Ui.Styles

import Ui.Button

{-| Representation of a button group:
  - **disabled** - Whether or not the button group is disabled
  - **readonly** - Whether or not the button group is readonly
  - **items** - The label and action for each button
  - **kind** - The type of the buttons
  - **size** - The size of the buttons
-}
type alias Model msg =
  { items : List ( String, msg )
  , disabled : Bool
  , readonly : Bool
  , kind : String
  , size : String
  }


{-| Initializes a button group with the given data.

    buttonGroup =
      Ui.ButtonGroup.model
        [ ("Download", Download)
        , ("Export", Export)
        ]
-}
model : List ( String, msg ) -> Model msg
model items =
  { disabled = False
  , readonly = False
  , kind = "primary"
  , size = "medium"
  , items = items
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
    (Ui.Styles.apply defaultStyle)
    (List.map (renderButton model) model.items)


{-| Renders a button for the button group.
-}
renderButton : Model msg -> ( String, msg ) -> Html.Html msg
renderButton model ( label, action ) =
  Ui.Button.view
    action
    { disabled = model.disabled
    , readonly = model.readonly
    , kind = model.kind
    , size = model.size
    , text = label
    }
