module Ui.Styles.Theme exposing (..)

{-| This module contains the theme for the components.

@docs Theme, default
-}

import Css.Properties exposing (..)


{-| Representation of a theme.
-}
type alias Theme =
  { borderRadius: String
  , colors:
    { background: { color: String, bw: String }
    , disabledSecondary: { color: String, bw: String }
    , secondary: { color: String, bw: String }
    , disabled: { color: String, bw: String }
    , success: { color: String, bw: String }
    , warning: { color: String, bw: String }
    , primary: { color: String, bw: String}
    , danger: { color: String, bw: String }
    , input: { color: String, bw: String }
    , inputSecondary: { color: String, bw: String }
    , focus: { color: String, bw: String }
    , border: String
    }
  , fontFamily: String
  , focusShadows: List BoxShadow
  , focusShadowsIdle: List BoxShadow
  }


{-| The default theme.
-}
default : Theme
default =
  { fontFamily = "-apple-system, system-ui, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif"
  , borderRadius = (px 2)
  , focusShadowsIdle =
    [ { x = "0", y = "0", blur = "0", spread = (px 1), color = "transparent", inset = True }
    , { x = "0", y = "0", blur = px 4, spread = "0", color = "transparent", inset = False }
    , { x = "0", y = "0", blur = px 4, spread = "0", color = "transparent", inset = True }
    ]
  , focusShadows =
    [ { x = "0", y = "0", blur = "0", spread = (px 1), color = "#00C0FF", inset = True }
    , { x = "0", y = "0", blur = px 4, spread = "0", color = "rgba(0,192,255,.5)", inset = False }
    , { x = "0", y = "0", blur = px 4, spread = "0", color = "rgba(0,192,255,.5)", inset = True }
    ]
  , colors =
    { background = { color = "#F5F5F5", bw = "#626262" }
    , disabled = { color = "#d7d7d7", bw = "#9a9a9a" }
    , disabledSecondary = { color = "#979797", bw = "#e6e6e6" }
    , secondary = { color = "#5D7889", bw = "#FFF" }
    , warning = { color = "#FF9730 ", bw = "#FFF" }
    , primary = { color = "#158DD8", bw = "#FFF" }
    , success = { color = "#4DC151", bw = "#FFF" }
    , inputSecondary = { color = "#f3f3f3", bw="#616161" }
    , input = { color ="#FDFDFD", bw = "#656565" }
    , danger = { color = "#E04141", bw = "#FFF" }
    , focus = { color = "#00C0FF", bw = "#FFF" }
    , border = "rgba(0,0,0,0.075)"
    }
  }
