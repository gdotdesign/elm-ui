module Ui.IconButton
  ( Model, init, view
  , primary, primarySmall, primaryBig
  , secondaryBig, secondarySmall, secondary
  , warningBig, warningSmall, warning
  , successBig, successSmall, success
  , dangerBig, dangerSmall, danger) where

{-| Button with an icon either on the left or right side.

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
-}
import Html exposing (node, text)
import Html.Lazy

import Ui.Button exposing (attributes)
import Ui

{-| Representation of an icon button. -}
type alias Model =
  { disabled : Bool
  , glyph : String
  , text : String
  , kind : String
  , side : String
  , size : String
  }

{-| Initializes an icon button with a glyph and text.

    IconButton.initialite "android-download" "Download"
-}
init : String -> String -> Model
init glyph text =
  { disabled = False
  , kind = "primary"
  , size = "medium"
  , glyph = glyph
  , side = "left"
  , text = text
  }

{-| Renders an icon button. -}
view : Signal.Address a -> a -> Model -> Html.Html
view address action model =
  Html.Lazy.lazy3 render address action model

{-| Renders a "medium primary" icon button with the given text, glyph and size. -}
primary : String -> String -> String -> Signal.Address a -> a -> Html.Html
primary text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "medium" "primary" glyph side)

{-| Renders a "small primary" icon button with the given text, glyph and size. -}
primarySmall : String -> String -> String -> Signal.Address a -> a -> Html.Html
primarySmall text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "small" "primary" glyph side)

{-| Renders a "big primary" icon button with the given text, glyph and size. -}
primaryBig : String -> String -> String -> Signal.Address a -> a -> Html.Html
primaryBig text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "big" "primary" glyph side)

{-| Renders a "medium danger" icon button with the given text, glyph and size. -}
danger : String -> String -> String -> Signal.Address a -> a -> Html.Html
danger text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "medium" "danger" glyph side)

{-| Renders a "small danger" icon button with the given text, glyph and size. -}
dangerSmall : String -> String -> String -> Signal.Address a -> a -> Html.Html
dangerSmall text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "small" "danger" glyph side)

{-| Renders a "big danger" icon button with the given text, glyph and size. -}
dangerBig : String -> String -> String -> Signal.Address a -> a -> Html.Html
dangerBig text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "big" "danger" glyph side)

{-| Renders a "medium secondary" icon button with the given text, glyph and size. -}
secondary : String -> String -> String -> Signal.Address a -> a -> Html.Html
secondary text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "medium" "secondary" glyph side)

{-| Renders a "small secondary" icon button with the given text, glyph and size. -}
secondarySmall : String -> String -> String -> Signal.Address a -> a -> Html.Html
secondarySmall text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "small" "secondary" glyph side)

{-| Renders a "big secondary" icon button with the given text, glyph and size. -}
secondaryBig : String -> String -> String -> Signal.Address a -> a -> Html.Html
secondaryBig text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "big" "secondary" glyph side)

{-| Renders a "medium success" icon button with the given text, glyph and size. -}
success : String -> String -> String -> Signal.Address a -> a -> Html.Html
success text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "medium" "success" glyph side)

{-| Renders a "small success" icon button with the given text, glyph and size. -}
successSmall : String -> String -> String -> Signal.Address a -> a -> Html.Html
successSmall text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "small" "success" glyph side)

{-| Renders a "big success" icon button with the given text, glyph and size. -}
successBig : String -> String -> String -> Signal.Address a -> a -> Html.Html
successBig text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "big" "success" glyph side)

{-| Renders a "medium warning" icon button with the given text, glyph and size. -}
warning : String -> String -> String -> Signal.Address a -> a -> Html.Html
warning text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "medium" "warning" glyph side)

{-| Renders a "small warning" icon button with the given text, glyph and size. -}
warningSmall : String -> String -> String -> Signal.Address a -> a -> Html.Html
warningSmall text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "small" "warning" glyph side)

{-| Renders a "big warning" icon button with the given text, glyph and size. -}
warningBig : String -> String -> String -> Signal.Address a -> a -> Html.Html
warningBig text glyph side address action =
  Html.Lazy.lazy3 render address action (model text "big" "warning" glyph side)

-- Generates a model from the given arguments.
model : String -> String -> String -> String -> String -> Model
model text size kind glyph side =
  { disabled = False
  , glyph = glyph
  , kind = kind
  , size = size
  , side = side
  , text = text
  }

-- Render internal.
render : Signal.Address a -> a -> Model -> Html.Html
render address action model =
  let
    icon = Ui.icon model.glyph False []

    span = node "span" [] [text model.text]

    children =
      if model.side == "left" then [icon, span] else [span, icon]
  in
    node
      "ui-icon-button"
      (attributes address action model)
      children
