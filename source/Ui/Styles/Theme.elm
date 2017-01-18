module Ui.Styles.Theme exposing (..)

import Css.Properties exposing (..)

type alias Theme =
  { borderRadius: String
  , colors:
    { background: { color: String, bw: String }
    , secondary: { color: String, bw: String }
    , disabled: { color: String, bw: String }
    , success: { color: String, bw: String }
    , warning: { color: String, bw: String }
    , primary: { color: String, bw: String}
    , danger: { color: String, bw: String }
    }
  , fontFamily: String
  }

default : Theme
default =
  { fontFamily = "-apple-system, system-ui, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif"
  , borderRadius = (px 2)
  , colors =
    { background = { color = "#F5F5F5", bw = "#626262" }
    , disabled = { color = "#d7d7d7", bw = "#565656" }
    , secondary = { color = "#5D7889", bw = "#FFF" }
    , warning = { color = "#FF9730 ", bw = "#FFF" }
    , primary = { color = "#158DD8", bw = "#FFF" }
    , success = { color = "#4DC151", bw = "#FFF" }
    , danger = { color = "#E04141", bw = "#FFF" }
    }
  }
