module Ui.Styles exposing (..)

import Css.Properties exposing (..)
import Css exposing (..)

import Html

import Ui.Styles.Theme exposing (default)

import Ui.Styles.Container as Container
import Ui.Styles.Button as Button

{-| Renders the stylesheet.
-}
embed : Html.Html msg
embed =
  Css.embed
    [ selector "*"
      [ property "-webkit-touch-callout" none
      , boxSizing borderBox
      ]

    , selector "html"
      [ property "-webkit-tap-highlight-color" "rgba(0,0,0,0)"
      ]

    , selector "body"
      [ fontSize (px 16)
      , margin zero
      ]

    , Button.style default
    , Container.style
    ]
