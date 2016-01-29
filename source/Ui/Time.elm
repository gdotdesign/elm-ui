module Ui.Time where

{-| A component that displays relative time.

# Model
@docs Model, init

# View
@docs view
-}
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
  }

init : Date.Date -> Model
init date =
  { date = date
  , format = "%Y-%m-%d %H:%M:%S"
  }

view : Model -> Html.Html
view model =
  node "ui-time"
    [title (format model.format model.date)]
    [text (Ext.Date.ago model.date (Ext.Date.now ()))]
