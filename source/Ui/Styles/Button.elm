module Ui.Styles.Button exposing (style)

import Css exposing (..)

import Ui.Styles.Ripple as Ripple

style : Node
style =
  selector "ui-button"
    [ Ripple.style ]
