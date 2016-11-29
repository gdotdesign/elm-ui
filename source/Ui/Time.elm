effect module Ui.Time where { subscription = MySub } exposing
  (Model, Msg, initModel, subscriptions, update, view, render, updateTime)

{-| A component that displays time with a formatting function (defaults to
relative time like: 10 minutes ago).

# Model
@docs Model, Msg, initModel, subscriptions, update

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

import Task exposing (Task)
import Process


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

    time = Ui.Time.initModel (Date.fromString '2016-05-28')
-}
initModel : Date.Date -> Model
initModel date =
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
  subscription (Sub Tick)


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


--- EFFECTS

type alias State =
  Maybe Platform.ProcessId

type MySub msg =
  Sub (Time -> msg)

init : Task Never State
init =
  Task.succeed Nothing

subMap : (a -> b) -> MySub a -> MySub b
subMap f (Sub msg) =
  Sub (f << msg)

onEffects : Platform.Router msg () -> List (MySub msg) -> State -> Task Never State
onEffects router subs state =
  let
    haveSubs = not (List.isEmpty subs)
  in
    case Debug.log "" (state, haveSubs) of
      (Just id, True) ->
        Task.succeed (Just id)
        -- send updates
      (Nothing, True) ->
        Process.spawn (setInterval 5000 (Platform.sendToSelf router ()))
          |> Task.andThen (\id -> Task.succeed (Just id))
        -- start process
      (Just id, False) ->
        -- stop process
        Process.kill id
          |> Task.andThen (\_ -> Task.succeed Nothing)
      (Nothing, False) ->
        Task.succeed Nothing


onSelfMsg : Platform.Router msg () -> () -> State -> Task Never State
onSelfMsg router _ state =
  let
    _ = Debug.log "WTF" (Ext.Date.now ())
  in
    Task.succeed state

setInterval : Time -> Task Never () -> Task x Never
setInterval =
  Native.DateTime.setInterval
