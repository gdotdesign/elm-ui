module Ui.SearchInput exposing
  ( Model, Msg, init, onChange, update, view, render, setValue, placeholder
  , showClearIcon, timeout )

{-| A input component for handling searches. The component will send the
current value of the input when it has settled after the given timeout.

# Model
@docs Model, Msg, init, update

# DSL
@docs placeholder, showClearIcon, timeout

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html exposing (node)
import Html.Lazy

import Time exposing (Time)
import Ext.Date
import Process
import Task

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Input
import Ui.Icons
import Ui

import Ui.Styles.SearchInput exposing (defaultStyle)
import Ui.Styles

{-| Representation of a search input:
  - **timeout** - The duration after which the input is considered settled
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **timestamp** - The timestamp of the last edit
  - **input** - The model of the input component
  - **uid** - The unique identifier of the input
  - **value** - The current value of the input
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
  | Update Time


{-| Initializes a search input.

    searchInput = Ui.SearchInput.init ()
-}
init : () -> Model
init _ =
  { input = Ui.Input.init ()
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , timeout = 1000
  , timestamp = 0
  , value = ""
  }


{-| Sets the placeholder of a search input.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | input = Ui.Input.placeholder value model.input }


{-| Sets whether or not to show a clear icon for a search input.
-}
showClearIcon : Bool -> Model -> Model
showClearIcon value model =
  { model | input = Ui.Input.showClearIcon value model.input }


{-| Sets the timeout (in milliseconds) of a search input.
-}
timeout : Time -> Model -> Model
timeout value model =
  { model | timeout = value }


{-| Subscribe to the changes of a search input.

    subscriptions = Ui.SearchInput.onChange SearchInputChanged searchInput
-}
onChange : (String -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenString model.uid msg


{-| Updates a search input.

    ( updatedSearchInput, cmd ) = Ui.SearchInput.update msg searchInput
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Update time ->
      let
        value =
          model.input.value
      in
        if time == (model.timestamp + model.timeout)
        && model.value /= value
        then
          ( { model | value = value }
          , Emitter.sendString model.uid value
          )
        else
          ( model, Cmd.none )

    Input msg ->
      let
        justNow =
          Ext.Date.nowTime ()

        ( input, inputCmd ) =
          Ui.Input.update msg model.input

        updatedModel =
          { model
            | timestamp = justNow
            , input = input
          }

        delayedUpdateCmd =
          Task.perform
            (\_ -> (Update (justNow + model.timeout)))
            (Process.sleep model.timeout)

        cmd =
          Cmd.batch
            [ Cmd.map Input inputCmd
            , delayedUpdateCmd
            ]
      in
        ( updatedModel, cmd )


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
      (Ui.Styles.apply defaultStyle)
      [ Html.map Input (Ui.Input.view updatedInput)
      , Ui.Icons.search []
      ]


{-| Sets the value of a search input.

    ( updatedSearchInput, cmd ) =
      Ui.SearchInput.setValue "new value" searchInput
-}
setValue : String -> Model -> ( Model, Cmd Msg)
setValue value model =
  let
    ( input, cmd ) =
      Ui.Input.setValue value model.input
  in
    ( { model | value = value, input = input }, Cmd.map Input cmd )
