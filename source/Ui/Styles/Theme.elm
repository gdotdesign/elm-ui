module Ui.Styles.Theme exposing (..)

import Css.Properties exposing (..)

type alias Theme =
  { borderRadius: String
  , colors:
    { background: { color: String, bw: String }
    , secondary: { color: String, bw: String }
    , disabled: { color: String, bw: String }
    , primary: { color: String, bw: String}
    }
  }

default : Theme
default =
  { borderRadius = (px 2)
  , colors =
    { background = { color = "#F5F5F5", bw = "#626262" }
    , disabled = { color = "#d7d7d7", bw = "#565656" }
    , secondary = { color = "#5D7889", bw = "#FFF" }
    , primary = { color = "#158DD8", bw = "#FFF" }
    }
  }
