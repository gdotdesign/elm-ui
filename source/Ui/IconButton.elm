module Ui.IconButton exposing (Model, model, render, view)

{-| Button with an icon either on the left or right side.

# Model
@docs Model, model

# View
@docs render, view
-}

import Html exposing (node, text)
import Html.Lazy

import Ui.Button exposing (attributes)
import Ui.Helpers.Ripple as Ripple
import Ui

import Ui.Styles.IconButton exposing (defaultStyle)

{-| Representation of an icon button:
  - **disabled** - Whether or not the icon button is disabled
  - **readonly** - Whether or not the icon button is readonly
  - **glyph** - The glyph to use, usually an SVG node
  - **text** - The text of the icon button
  - **kind** - The type of the icon button
  - **side** - The side to display the icon
  - **size** - The size of the icon button
-}
type alias Model msg =
  { glyph : Html.Html msg
  , disabled : Bool
  , readonly : Bool
  , text : String
  , kind : String
  , side : String
  , size : String
  }


{-| Initializes an icon button with a glyph and text.

    iconButton =
      Ui.IconButton.model "android-download" Ui.Icons.close
-}
model : String -> Html.Html msg -> Model msg
model text glyph =
  { disabled = False
  , readonly = False
  , kind = "primary"
  , size = "medium"
  , glyph = glyph
  , side = "left"
  , text = text
  }


{-| Renders an icon button.

    Ui.IconButton.render msg model
-}
render : msg -> Model msg -> Html.Html msg
render msg model =
  let
    icon =
      node "ui-icon-button-icon" [] [ model.glyph ]

    span =
      node "span" [] [ text model.text ]

    children =
      if model.side == "left" then
        [ icon, span ]
      else
        [ span, icon ]
  in
    node
      "ui-icon-button"
      (attributes defaultStyle msg model)
      ([ Ripple.view ] ++ children)


{-| Lazily renders an icon button.

    Ui.IconButton.view msg model
-}
view : msg -> Model msg -> Html.Html msg
view msg model =
  Html.Lazy.lazy2 render msg model
