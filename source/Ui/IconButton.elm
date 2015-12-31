module Ui.IconButton
  (Model, init, view) where

{-| Button with an icon either on the left or right side.

# Model
@docs Model, init

# View
@docs view
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

{-| Initializes an icon button with a glyph and text. -}
init : String -> String -> Model
init glyph text =
  { disabled = False
  , text = text
  , glyph = glyph
  , kind = "primary"
  , side = "left"
  , size = "medium"
  }

{-| Renders an icon button. -}
view : Signal.Address a -> a -> Model -> Html.Html
view address action model =
  Html.Lazy.lazy3 render address action model

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
