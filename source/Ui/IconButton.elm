module Ui.IconButton exposing
  (Model, init, render, view
  , primary, primarySmall, primaryBig
  , secondary, secondaryBig, secondarySmall
  , warning, warningBig, warningSmall
  , success, successBig, successSmall
  , danger, dangerBig, dangerSmall)

{-| Button with an icon either on the left or right side.

# Model
@docs Model, init

# View
@docs render, view

# View Variations
@docs primary, primaryBig, primarySmall
@docs secondary, secondaryBig, secondarySmall
@docs warning, warningBig, warningSmall
@docs success, successBig, successSmall
@docs danger, dangerBig, dangerSmall
-}

import Html exposing (node, text)
import Html.Lazy

import Svg.Attributes exposing (cx, cy, r, viewBox)
import Svg exposing (svg, circle)

import Ui.Button exposing (attributes)
import Ui


{-| Representation of an icon button:
  - **disabled** - Whether or not the icon button is disabled
  - **glyph** - The glyph to use form IonIcons
  - **text** - The text of the icon button
  - **kind** - The type of the icon button
  - **side** - The side to display the icon
  - **size** - The size of the icon button
-}
type alias Model =
  { disabled : Bool
  , glyph : String
  , text : String
  , kind : String
  , side : String
  , size : String
  }


{-| Initializes an icon button with a glyph and text.

    iconButton = Ui.IconButton.init "android-download" "Download"
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


{-| Renders an icon button.

    Ui.IconButton.render msg model
-}
render : msg -> Model -> Html.Html msg
render msg model =
  let
    icon =
      Ui.icon model.glyph False []

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
      (attributes msg model)
      ([ svg [ viewBox "0 0 100 100" ]
         [ circle [cx "50", cy "50", r "50"] []
         ]
       ] ++ children)


{-| Lazily renders an icon button.

    Ui.IconButton.view msg model
-}
view : msg -> Model -> Html.Html msg
view msg model =
  Html.Lazy.lazy2 render msg model


{-| Lazily renders a "medium primary" icon button with the given text, glyph and size.
-}
primary : String -> String -> String -> msg -> Html.Html msg
primary text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "medium" "primary" glyph side)


{-| Lazily renders a "small primary" icon button with the given text, glyph and size.
-}
primarySmall : String -> String -> String -> msg -> Html.Html msg
primarySmall text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "small" "primary" glyph side)


{-| Lazily renders a "big primary" icon button with the given text, glyph and size.
-}
primaryBig : String -> String -> String -> msg -> Html.Html msg
primaryBig text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "big" "primary" glyph side)


{-| Lazily renders a "medium danger" icon button with the given text, glyph and size.
-}
danger : String -> String -> String -> msg -> Html.Html msg
danger text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "medium" "danger" glyph side)


{-| Lazily renders a "small danger" icon button with the given text, glyph and size.
-}
dangerSmall : String -> String -> String -> msg -> Html.Html msg
dangerSmall text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "small" "danger" glyph side)


{-| Lazily renders a "big danger" icon button with the given text, glyph and size.
-}
dangerBig : String -> String -> String -> msg -> Html.Html msg
dangerBig text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "big" "danger" glyph side)


{-| Lazily renders a "medium secondary" icon button with the given text, glyph and size.
-}
secondary : String -> String -> String -> msg -> Html.Html msg
secondary text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "medium" "secondary" glyph side)


{-| Lazily renders a "small secondary" icon button with the given text, glyph and size.
-}
secondarySmall : String -> String -> String -> msg -> Html.Html msg
secondarySmall text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "small" "secondary" glyph side)


{-| Lazily renders a "big secondary" icon button with the given text, glyph and size.
-}
secondaryBig : String -> String -> String -> msg -> Html.Html msg
secondaryBig text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "big" "secondary" glyph side)


{-| Lazily renders a "medium success" icon button with the given text, glyph and size.
-}
success : String -> String -> String -> msg -> Html.Html msg
success text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "medium" "success" glyph side)


{-| Lazily renders a "small success" icon button with the given text, glyph and size.
-}
successSmall : String -> String -> String -> msg -> Html.Html msg
successSmall text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "small" "success" glyph side)


{-| Lazily renders a "big success" icon button with the given text, glyph and size.
-}
successBig : String -> String -> String -> msg -> Html.Html msg
successBig text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "big" "success" glyph side)


{-| Lazily renders a "medium warning" icon button with the given text, glyph and size.
-}
warning : String -> String -> String -> msg -> Html.Html msg
warning text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "medium" "warning" glyph side)


{-| Lazily renders a "small warning" icon button with the given text, glyph and size.
-}
warningSmall : String -> String -> String -> msg -> Html.Html msg
warningSmall text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "small" "warning" glyph side)


{-| Lazily renders a "big warning" icon button with the given text, glyph and size.
-}
warningBig : String -> String -> String -> msg -> Html.Html msg
warningBig text glyph side msg =
  Html.Lazy.lazy2 render msg (model text "big" "warning" glyph side)


{-| Generates a model from the given arguments.
-}
model : String -> String -> String -> String -> String -> Model
model text size kind glyph side =
  { disabled = False
  , glyph = glyph
  , kind = kind
  , size = size
  , side = side
  , text = text
  }
