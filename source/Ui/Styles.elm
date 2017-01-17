module Ui.Styles exposing (..)

import Css exposing (..)
import Html

import Ui.Styles.Button as Button

{-| Renders the stylesheet.
-}
embed : Html.Html msg
embed =
  Css.embed Button.style
