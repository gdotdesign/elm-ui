module Ui.Button
  ( Model, init, view, attributes
  , primaryBig, primarySmall, primary
  , secondaryBig, secondarySmall, secondary
  , warningBig, warningSmall, warning
  , successBig, successSmall, success
  , dangerBig, dangerSmall, danger) where

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
                        , kind = "primary"
                        , text = "Button"
                        , size = "medium"
                        }
-}
view : Signal.Address a -> a -> Model -> Html.Html
view address action model =
  Html.Lazy.lazy3 render address action model

{-| Renders a **big primary** button with the given text. -}
primaryBig : String -> Signal.Address a -> a -> Html.Html
primaryBig title address action =
  Html.Lazy.lazy3 render address action (model title "primary" "big")

{-| Renders a **small primary** button with the given text. -}
primarySmall : String -> Signal.Address a -> a -> Html.Html
primarySmall title address action =
  Html.Lazy.lazy3 render address action (model title "primary" "small")

{-| Renders a **medium primary** (normal) button with the given text. -}
primary : String -> Signal.Address a -> a -> Html.Html
primary title address action =
  Html.Lazy.lazy3 render address action (model title "primary" "medium")

{-| Renders a **big secondary** button with the given text. -}
secondaryBig : String -> Signal.Address a -> a -> Html.Html
secondaryBig title address action =
  Html.Lazy.lazy3 render address action (model title "secondary" "big")

{-| Renders a **small secondary** button with the given text. -}
secondarySmall : String -> Signal.Address a -> a -> Html.Html
secondarySmall title address action =
  Html.Lazy.lazy3 render address action (model title "secondary" "small")

{-| Renders a **medium secondary** (normal) button with the given text. -}
secondary : String -> Signal.Address a -> a -> Html.Html
secondary title address action =
  Html.Lazy.lazy3 render address action (model title "secondary" "medium")

{-| Renders a **big warning** button with the given text. -}
warningBig : String -> Signal.Address a -> a -> Html.Html
warningBig title address action =
  Html.Lazy.lazy3 render address action (model title "warning" "big")

{-| Renders a **small warning** button with the given text. -}
warningSmall : String -> Signal.Address a -> a -> Html.Html
warningSmall title address action =
  Html.Lazy.lazy3 render address action (model title "warning" "small")

{-| Renders a **medium warning** (normal) button with the given text. -}
warning : String -> Signal.Address a -> a -> Html.Html
warning title address action =
  Html.Lazy.lazy3 render address action (model title "warning" "medium")

{-| Renders a **big success** button with the given text. -}
successBig : String -> Signal.Address a -> a -> Html.Html
successBig title address action =
  Html.Lazy.lazy3 render address action (model title "success" "big")

{-| Renders a **small success** button with the given text. -}
successSmall : String -> Signal.Address a -> a -> Html.Html
successSmall title address action =
  Html.Lazy.lazy3 render address action (model title "success" "small")

{-| Renders a **medium success** (normal) button with the given text. -}
success : String -> Signal.Address a -> a -> Html.Html
success title address action =
  Html.Lazy.lazy3 render address action (model title "success" "medium")

{-| Renders a **big danger** button with the given text. -}
dangerBig : String -> Signal.Address a -> a -> Html.Html
dangerBig title address action =
  Html.Lazy.lazy3 render address action (model title "danger" "big")

{-| Renders a **small danger** button with the given text. -}
dangerSmall : String -> Signal.Address a -> a -> Html.Html
dangerSmall title address action =
  Html.Lazy.lazy3 render address action (model title "danger" "small")

{-| Renders a **medium danger** (normal) button with the given text. -}
danger : String -> Signal.Address a -> a -> Html.Html
danger title address action =
  Html.Lazy.lazy3 render address action (model title "danger" "medium")

-- Generate model from text kind and size.
model : String -> String -> String -> Model
model title kind size =
  { disabled = False
  , text = title
  , kind = kind
  , size = size
  }

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
