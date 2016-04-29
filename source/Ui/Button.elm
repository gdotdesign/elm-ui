module Ui.Button exposing
  ( Model, init, view, attributes
  , primaryBig, primarySmall, primary
  , secondaryBig, secondarySmall, secondary
  , warningBig, warningSmall, warning
  , successBig, successSmall, success
  , dangerBig, dangerSmall, danger) -- where

{-| Basic button component that implements:
  - 5 different types (primary, secondary, warning, danger, success)
  - 3 different sizes (small, medium, big)
  - disabled state

# Model
@docs Model, init

# View
@docs view

# View Variations
@docs primary, primaryBig, primarySmall
@docs secondary, secondaryBig, secondarySmall
@docs warning, warningBig, warningSmall
@docs success, successBig, successSmall
@docs danger, dangerBig, dangerSmall

# Functions
@docs attributes
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node, text)

import Ui

{-| Representation of a button:
  - **disabled** - Whether or not the button is disabled
  - **kind** - The type of the button
  - **size** - The size of the button
  - **text** - The text of the button
-}
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
                        , kind = "primary"
                        , text = "Button"
                        , size = "medium"
                        }
-}
view : msg -> Model -> Html.Html msg
view msg model =
  render msg model

{-| Renders a **big primary** button with the given text. -}
primaryBig : String -> msg -> Html.Html msg
primaryBig title msg =
  render msg (model title "primary" "big")

{-| Renders a **small primary** button with the given text. -}
primarySmall : String -> msg -> Html.Html msg
primarySmall title msg =
  render msg (model title "primary" "small")

{-| Renders a **medium primary** (normal) button with the given text. -}
primary : String -> msg -> Html.Html msg
primary title msg =
  render msg (model title "primary" "medium")

{-| Renders a **big secondary** button with the given text. -}
secondaryBig : String -> msg -> Html.Html msg
secondaryBig title msg =
  render msg (model title "secondary" "big")

{-| Renders a **small secondary** button with the given text. -}
secondarySmall : String -> msg -> Html.Html msg
secondarySmall title msg =
  render msg (model title "secondary" "small")

{-| Renders a **medium secondary** (normal) button with the given text. -}
secondary : String -> msg -> Html.Html msg
secondary title msg =
  render msg (model title "secondary" "medium")

{-| Renders a **big warning** button with the given text. -}
warningBig : String -> msg -> Html.Html msg
warningBig title msg =
  render msg (model title "warning" "big")

{-| Renders a **small warning** button with the given text. -}
warningSmall : String -> msg -> Html.Html msg
warningSmall title msg =
  render msg (model title "warning" "small")

{-| Renders a **medium warning** (normal) button with the given text. -}
warning : String -> msg -> Html.Html msg
warning title msg =
  render msg (model title "warning" "medium")

{-| Renders a **big success** button with the given text. -}
successBig : String -> msg -> Html.Html msg
successBig title msg =
  render msg (model title "success" "big")

{-| Renders a **small success** button with the given text. -}
successSmall : String -> msg -> Html.Html msg
successSmall title msg =
  render msg (model title "success" "small")

{-| Renders a **medium success** (normal) button with the given text. -}
success : String -> msg -> Html.Html msg
success title msg =
  render msg (model title "success" "medium")

{-| Renders a **big danger** button with the given text. -}
dangerBig : String -> msg -> Html.Html msg
dangerBig title msg =
  render msg (model title "danger" "big")

{-| Renders a **small danger** button with the given text. -}
dangerSmall : String -> msg -> Html.Html msg
dangerSmall title msg =
  render msg (model title "danger" "small")

{-| Renders a **medium danger** (normal) button with the given text. -}
danger : String -> msg -> Html.Html msg
danger title msg =
  render msg (model title "danger" "medium")

-- Generate model from text kind and size.
model : String -> String -> String -> Model
model title kind size =
  { disabled = False
  , text = title
  , kind = kind
  , size = size
  }

-- Render internal.
render : msg -> Model -> Html.Html msg
render msg model =
  node "ui-button"
    (attributes msg model)
    [node "span" [] [text model.text]]

{-| Creates the attributes for a button that contains events, tabindex and
classes. -}
attributes : msg
           -> { b | disabled : Bool, kind : String, size : String }
           -> List (Html.Attribute msg)
attributes msg model =
  let
    actions =
      Ui.enabledActions { disabled = model.disabled
                        , readonly = False
                        }
        [ onClick msg
        , onKeys [ (13, msg)
                 , (32, msg)
                 ]
        ]
  in
    [ classList
      [ ("disabled", model.disabled)
      , ("ui-button-" ++ model.size, True)
      , ("ui-button-" ++ model.kind, True)
      ]
    ] ++ (Ui.tabIndex model) ++ actions
