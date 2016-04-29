module Ui.SearchInput exposing (Model, Msg, init, subscribe, update, view, setValue)

{-| A input component for handling searches. The component will send the
current value of the input when it has settled after the given timeout.

# Model
@docs Model, Msg, init, subscribe, update, setValue

# View
@docs view
-}

-- where

import Html.Attributes exposing (classList)
import Html exposing (node)
import Html.App

import Time exposing (Time)
import Ext.Date
import Process
import Task
import Date

import Ui.Helpers.Emitter as Emitter
import Ui.Input
import Ui

import Native.Uid


{-| Representation of a search input:
  - **timeout** - The duration after which the input is considered settled
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **value** - The current value of the input
  - **timestamp** (internal) - The timestamp of the last edit
  - **input** (internal) - The model of the input component
-}
type alias Model =
  { input : Ui.Input.Model
  , timestamp : Time
  , disabled : Bool
  , readonly : Bool
  , value : String
  , timeout : Time
  , uid : String
  }


{-| Actions that a search input can make.
-}
type Msg
  = Input Ui.Input.Msg
  | Update Time ()
  | Tasks ()


{-| Initializes a search input with the given timeout.

    SearchInput.init 1000
-}
init : Time -> Model
init timeout =
  { input = Ui.Input.init "" "Search..."
  , timeout = timeout
  , disabled = False
  , readonly = False
  , timestamp = 0
  , value = ""
  , uid = Native.Uid.uid ()
  }


{-| Subscribe to the changes of an input.

    ...
    subscriptions =
      \model -> Ui.Input.subscribe InputChanged model.input
    ...
-}
subscribe : (String -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listenString model.uid msg


{-| Updates a search input.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Update time _ ->
      let
        value =
          model.input.value
      in
        if
          time
            == (model.timestamp + model.timeout)
            && model.value
            /= value
        then
          ( { model | value = value }
          , Emitter.sendString model.uid value
          )
        else
          ( model, Cmd.none )

    Input act ->
      let
        justNow =
          Ext.Date.nowTime Nothing

        ( input, effect2 ) =
          Ui.Input.update act model.input

        updatedModel =
          { model
            | input = input
            , timestamp = justNow
          }

        cmd =
          Task.perform
            Tasks
            (Update (justNow + model.timeout))
            (Process.sleep model.timeout)
      in
        ( updatedModel, cmd )

    Tasks _ ->
      ( model, Cmd.none )


{-| Renders a search input.
-}
view : Model -> Html.Html Msg
view model =
  render model



{- Renders a search input.
-}
render : Model -> Html.Html Msg
render { input, disabled, readonly } =
  let
    updatedInput =
      { input
        | disabled = disabled
        , readonly = readonly
      }
  in
    node
      "ui-search-input"
      []
      [ Ui.icon "search" False []
      , Html.App.map Input (Ui.Input.view updatedInput)
      ]


{-| Sets the value of the model.
-}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value, input = Ui.Input.setValue value model.input }
