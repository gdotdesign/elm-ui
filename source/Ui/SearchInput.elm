module Ui.SearchInput exposing
  (Model, Msg, init, subscribe, update, view, render, setValue)

{-| A input component for handling searches. The component will send the
current value of the input when it has settled after the given timeout.

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Attributes exposing (classList)
import Html exposing (node)
import Html.Lazy
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
  - **input** - The model of the input component
  - **timestamp** - The timestamp of the last edit
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **value** - The current value of the input
  - **timeout** - The duration after which the input is considered settled
  - **uid** - The unique identifier of the input
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


{-| Messages that an search input can receive.
-}
type Msg
  = Input Ui.Input.Msg
  | Update Time ()
  | Tasks ()


{-| Initializes a search input with the given timeout.

    searchInput = Ui.SearchInput.init 1000 "Placeholder..."
-}
init : Time -> String -> Model
init timeout placeholder =
  { input = Ui.Input.init "" placeholder
  , uid = Native.Uid.uid ()
  , timeout = timeout
  , disabled = False
  , readonly = False
  , timestamp = 0
  , value = ""
  }


{-| Subscribe to the changes of a search input.

    ...
    subscriptions =
      \model -> Ui.SearchInput.subscribe SearchInputChanged model.searchInput
    ...
-}
subscribe : (String -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listenString model.uid msg


{-| Updates a search input.

    Ui.SearchInput.update msg searchInput
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


{-| Lazily renders a search input.

    Ui.SearchInput.view searchInput
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model



{-| Renders a search input.

    Ui.SearchInput.render searchInput
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

    Ui.SearchInput.setValue "new value" searchInput
-}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value, input = Ui.Input.setValue value model.input }
