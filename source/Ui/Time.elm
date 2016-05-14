module Ui.Time exposing
  (Model, Msg, init, subscriptions, update, view, render, updateTime)

{-| A component that displays time with a formatting function (defaults to
relative time like: 10 minutes ago).

# Model
@docs Model, Msg, init, subscriptions, update

# View
@docs view, render

# Functions
@docs updateTime
-}

import Date.Extra.Config.Configs as DateConfigs
import Date.Extra.Format exposing (format)
import Time exposing (Time)
import Ext.Date
import Date

import Html.Attributes exposing (title)
import Html exposing (text, node)
import Html.Lazy

import Ui.Helpers.Emitter as Emitter


{-| Representation of a time component:
  - **format** - The function to format the date
  - **tooltipFormat** - The format of the tooltip (title)
  - **date** - The date to display
  - **now** - The date to calculate from
  - **locale** - The locale to use
-}
type alias Model =
  { format : Date.Date -> Date.Date -> String
  , tooltipFormat : String
  , date : Date.Date
  , now : Date.Date
  , locale : String
  }


{-| Messages that a time component can receive.
-}
type Msg
  = Tick Time


{-| Initializes a time component.

    time = Ui.Time.init (Date.fromString '2016-05-28')
-}
init : Date.Date -> Model
init date =
  { tooltipFormat = "%Y-%m-%d %H:%M:%S"
  , format = Ext.Date.ago
  , now = Ext.Date.now ()
  , locale = "en"
  , date = date
  }


{-| Subscriptions for a time component.

    ...
    subscriptions = \model-> Sub.map Time Ui.Time.subscriptions
    ...
-}
subscriptions : Sub Msg
subscriptions =
  Emitter.listenFloat "time-tick" Tick


{-| Updates a time component.

    Ui.Time.update msg time
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Tick now ->
      ( { model | now = Date.fromTime now }, Cmd.none )


{-| Lazily renders a time component.

    Ui.Time.view time
-}
view : Model -> Html.Html msg
view model =
  Html.Lazy.lazy render model


{-| Renders a time component.

    Ui.Time.render time
-}
render : Model -> Html.Html msg
render model =
  let
    titleText =
      format
        (DateConfigs.getConfig model.locale)
        model.tooltipFormat
        model.date
  in
    node
      "ui-time"
      [ title titleText ]
      [ text (model.format model.date model.now) ]


{-| Returns a command with the given time to send to all of the subscribers as
the **now** value.

    cmd = Ui.Time.updateTime now
-}
updateTime : Time -> Cmd msg
updateTime now =
  Emitter.sendFloat "time-tick" now
