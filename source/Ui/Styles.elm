module Ui.Styles exposing (..)

{-| This module contains the styles for all components.

@docs embed, embedSome, embedDefault
-}

import Css.Properties exposing (..)
import Css exposing (..)

import Html

import Ui.Styles.Theme exposing (Theme, default)

import Ui.Styles.ButtonGroup as ButtonGroup
import Ui.Styles.Container as Container
import Ui.Styles.Calendar as Calendar
import Ui.Styles.Checkbox as Checkbox
import Ui.Styles.Button as Button


{-| Renders the styles for the given components into a HTML tag.
-}
embedSome : List Node -> Html.Html msg
embedSome nodes =
  Css.embed nodes


{-| Renders the stylesheet with the default theme into an HTML tag.
-}
embedDefault : Html.Html msg
embedDefault =
  embed default


{-| Renders the stylesheet with the given theme into an HTML tag.
-}
embed : Theme -> Html.Html msg
embed theme =
  Css.embed
    [ ButtonGroup.style theme
    , Calendar.style theme
    , Checkbox.style theme
    , Button.style theme
    , Container.style
    ]
