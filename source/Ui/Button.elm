module Ui.Button exposing ( Model, model, view, render, attributes )

{-| Basic button component that implements:
  - **5 different types** (primary, secondary, warning, danger, success)
  - **3 different sizes** (small, medium, big)
  - **focus state** with animation
  - **disabled state**
  - **readonly state**

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

    Ui.Button.view address button
-}
view : msg -> Model -> Html.Html msg
view msg model =
  Html.Lazy.lazy2 render msg model


{-| Renders a button.
-}
render : msg -> Model -> Html.Html msg
render msg model =
  node
    "ui-button"
    (attributes msg model)
    [ Ripple.view
    , node "span" [] [ text model.text ]
    ]


{-| Creates the attributes for a button that contains events, tabindex and
classes.
-}
attributes :
  msg
  -> { b | disabled : Bool, kind : String, size : String, readonly : Bool }
  -> List (Html.Attribute msg)
attributes msg model =
  let
    disabled =
      if model.disabled then
        [ attribute "disabled" "" ]
      else
        []

    readonly =
      if model.readonly then
        [ attribute "readonly" "" ]
      else
        []

    actions =
      Ui.enabledActions model
        [ onClick msg
        , onKeys True
            [ ( 13, msg )
            , ( 32, msg )
            ]
        ]
  in
    [ [ attribute "size" model.size
      , attribute "kind" model.kind
      ]
    , Ui.tabIndex model
    , disabled
    , readonly
    , actions
    ]
      |> List.concat
