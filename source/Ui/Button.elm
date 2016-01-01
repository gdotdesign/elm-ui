module Ui.Button (Model, init, view, attributes) where

{-| Basic button component that implements:
  - 5 different types (primary, secondary, warning, danger, success)
  - 3 different sizes (small, medium, big)
  - disabled state

# Model
@docs Model, init

# View
@docs view

# Functions
@docs attributes
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)
import Html.Lazy

import Ui

{-| Representation of a button. -}
type alias Model =
  { disabled: Bool
  , kind: String
  , size: String
  , text: String
  }

{-| Initializes a button. -}
init : Model
init =
  { disabled = False
  , kind = "primary"
  , size = "medium"
  , text = ""
  }

{-| Renders a button.

    Button.view address { disabled = False
                        , kind = "Primary"
                        , text = "Button"
                        , size = "medium"
                        }
-}
view : Signal.Address a -> a -> Model -> Html.Html
view address action model =
  Html.Lazy.lazy3 render address action model

-- Render internal.
render : Signal.Address a -> a -> Model -> Html.Html
render address action model =
  node "ui-button"
    (attributes address action model)
    [node "span" [] [text model.text]]

{-| Creates the attributes for a button that contains events, tabindex and
classes. -}
attributes : Signal.Address a
           -> a
           -> { b | disabled : Bool, kind : String, size : String }
           -> List Html.Attribute
attributes address action model =
  let
    actions =
      Ui.enabledActions { disabled = model.disabled
                        , readonly = False
                        }
        [ onClick address action
        , onKeys address [ (13, action)
                         , (32, action)
                         ]
        ]
  in
    [ classList
      [ ("disabled", model.disabled)
      , ("ui-button-" ++ model.size, True)
      , ("ui-button-" ++ model.kind, True)
      ]
    ] ++ (Ui.tabIndex model) ++ actions
