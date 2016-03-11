module Ui.Time where

{-| A component that displays relative time.

# Model
@docs Model, init

# View
@docs view
-}
import Date.Config.Configs as DateConfigs
import Date.Format exposing (format)
import Ext.Date
import Date

import Html.Attributes exposing (title)
import Html exposing (text, node)

{-| Represents a relative time component:
  - **date** - The date to show relative time from
  - **format** - The format of the tooltip.
-}
type alias Model =
  { date: Date.Date
  , format : String
  , locale : String
  }

init : Date.Date -> Model
init date =
  { date = date
  , format = "%Y-%m-%d %H:%M:%S"
  , locale = "en"
  }

view : Model -> Html.Html
view model =
  node "ui-time"
    [title (format (DateConfigs.getConfig model.locale) model.format model.date)]
    [text (Ext.Date.ago model.date (Ext.Date.now ()))]
