module Ui.Styles.Theme exposing (..)

{-| This module contains the theme for the components.

@docs Theme, default
-}

import Css.Properties exposing (..)

{-| Representation of a theme.
-}
type alias Theme =
  { borderRadius: String
  , header :
    { colors :
      { backgroundBottom : String
      , backgroundTop : String
      , border : String
      , text : String
      }
    }
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
    , gray: { color: String, bw: String }
    , focus: { color: String, bw: String }
    , borderDisabled : String
    , border: String
    }
  , fontFamily: String
  , focusShadows: List BoxShadow
  , focusShadowsIdle: List BoxShadow
  , zIndexes :
    { notifications : Int
    , dropdown : Int
    , header : Int
    , modal : Int
    , fab : Int
    }
  , breadcrumbs :
    { background : String
    , borderColor : String
    , text : String
    }
  , chooser :
    { hoverColors : { background : String, text : String }
    , selectedColors : { background : String, text : String }
    , selectedHoverColors : { background : String, text : String }
    , intendedColors : { background : String, text : String }
    , intendedHoverColors : { background : String, text : String }
    , selectedIntendedColors : { background : String, text : String }
    , selectedIntendedHoverColors : { background : String, text : String }
    }
  , scrollbar :
    { thumbColor : String
    , thumbHoverColor : String
    , trackColor : String
    }
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
    { background = { color = "#F5F5F5", bw = "#707070" }
    , disabled = { color = "#d7d7d7", bw = "#9a9a9a" }
    , disabledSecondary = { color = "#a9a9a9", bw = "#cecece" }
    , secondary = { color = "#5D7889", bw = "#FFF" }
    , warning = { color = "#FF9730 ", bw = "#FFF" }
    , primary = { color = "#158DD8", bw = "#FFF" }
    , success = { color = "#4DC151", bw = "#FFF" }
    , gray = { color = "#E9E9E9", bw="#616161" }
    , inputSecondary = { color = "#f3f3f3", bw="#616161" }
    , input = { color ="#FDFDFD", bw = "#707070" }
    , danger = { color = "#E04141", bw = "#FFF" }
    , focus = { color = "#00C0FF", bw = "#FFF" }
    , borderDisabled = "#C7C7C7"
    , border = "#DDD"
    }
  , zIndexes =
    { notifications = 2000
    , dropdown = 1000
    , modal = 100
    , header = 50
    , fab = 90
    }
  , chooser =
    { hoverColors = { background = "#f0f0f0", text = "#707070" }
    , selectedColors = { background = "#158DD8", text = "#FFF" }
    , selectedHoverColors = { background = "#1f97e2", text = "#FFF" }
    , intendedColors = { background = "#EEE", text = "#707070" }
    , intendedHoverColors = { background = "#DDD", text = "#707070" }
    , selectedIntendedColors = { background = "#1070ac", text = "#FFF" }
    , selectedIntendedHoverColors = { background = "#0c5989", text = "#FFF" }
    }
  , breadcrumbs =
    { background = "#f1f1f1"
    , borderColor = "#d2d2d2"
    , text = "#4a4a4a"
    }
  , scrollbar =
    { thumbColor = "#d0d0d0"
    , thumbHoverColor = "#b8b8b8"
    , trackColor = "#e9e9e9"
    }
  , header =
    { colors =
      { backgroundBottom = "#158DD8"
      , backgroundTop = "#1692df"
      , border = "#137fc2"
      , text = "#FFF"
      }
    ,
    }
  }
