module Ui.Button exposing (Model, model, view, render, attributes)

{-| Thie module provides a basic button component with the following features:
  - **focus state** with ripple effect (Ui.Helpers.Ripple)
  - **disabled state** with a custom cursor
  - **readonly state** with a custom cursor

# Model
@docs Model, model

# View
@docs view, render

# Functions
@docs attributes
-}

import Html.Attributes exposing (attribute)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Ui.Styles.Button exposing (defaultStyle)
import Ui.Styles exposing (Style)

import Ui.Helpers.Ripple as Ripple
import Ui

{-| Representation of a button:
  - **disabled** - Whether or not the button is disabled
  - **readonly** - Whether or not the button is readonly
  - **kind** - The type of the button
  - **size** - The size of the button
  - **text** - The text of the button
-}
type alias Model =
  { disabled : Bool
  , readonly : Bool
  , kind : String
  , size : String
  , text : String
  }


{-| Initializes a button with the given data.

    button = Ui.Button.model "Upload" "primary" "medium"
-}
model : String -> String -> String -> Model
model text kind size =
  { disabled = False
  , readonly = False
  , text = text
  , kind = kind
  , size = size
  }


{-| Lazily renders a button.

    Ui.Button.view msg button
-}
view : msg -> Model -> Html.Html msg
view msg model =
  Html.Lazy.lazy2 render msg model


{-| Renders a button.

    Ui.Button.render msg button
-}
render : msg -> Model -> Html.Html msg
render msg model =
  node
    "ui-button"
    (attributes defaultStyle msg model)
    [ Ripple.view
    , node "span" [] [ text model.text ]
    ]


{-| Creates the attributes for a button that contains events, tabindex and
other attributes.
-}
attributes :
  Style
  -> msg
  -> { b | disabled : Bool, kind : String, size : String, readonly : Bool }
  -> List (Html.Attribute msg)
attributes styles msg model =
  [ Ui.attributeList
    [ ( "disabled", model.disabled )
    , ( "readonly", model.readonly )
    ]
  , [ attribute "size" model.size
    , attribute "kind" model.kind
    ]
  , Ui.enabledActions model
    [ onClick msg
    , onKeys True
      [ ( 13, msg )
      , ( 32, msg )
      ]
    ]
  , Ui.Styles.apply styles
  , Ui.tabIndex model
  ]
    |> List.concat
