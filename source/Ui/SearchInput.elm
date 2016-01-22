module Ui.SearchInput where

import Html.Attributes exposing (classList)
import Html exposing (node)
import Html.Lazy

import Signal exposing (forwardTo)
import Time exposing (Time)
import Ext.Signal
import Ext.Date
import Effects
import Task
import Date

import Ui.Input
import Ui

import Debug exposing (log)

type alias Model =
  { input : Ui.Input.Model
  , valueAddress : Maybe (Signal.Address String)
  , timestamp : Time
  , disabled : Bool
  , readonly : Bool
  , timeout : Time
  }

type Action
  = Input Ui.Input.Action
  | Update Time
  | Tasks ()

init : Time -> Model
init timeout =
  let
    input = Ui.Input.init ""
  in
    { input = { input | placeholder = "Search..." }
    , valueAddress = Nothing
    , timeout = timeout
    , disabled = False
    , readonly = False
    , timestamp = 0
    }

initWithAddress : Signal.Address String -> Time -> Model
initWithAddress valueAddress timeout =
  let
    model = init timeout
  in
    { model | valueAddress = Just valueAddress }

update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Update time ->
      let
        effect =
          if time == (model.timestamp + model.timeout) then
            Ext.Signal.sendAsEffect model.valueAddress model.input.value Tasks
          else
            Effects.none
      in
        (model, effect)
    Input act ->
      let
        justNow = Ext.Date.nowTime Nothing

        (input, effect2) = Ui.Input.update act model.input

        updatedModel =
          { model | input = input
                  , timestamp = justNow }
        effect =
          Task.andThen
            (Task.sleep model.timeout)
            (\_ -> Task.succeed (Update (justNow + model.timeout)))
            |> Effects.task
      in
        (updatedModel, effect)
    Tasks _ -> (model, Effects.none)

view: Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

render: Signal.Address Action -> Model -> Html.Html
render address {input, disabled, readonly} =
  let
    updatedInput = { input | disabled = disabled
                           , readonly = readonly }
  in
    node "ui-search-input" []
      [ Ui.icon "search" False []
      , Ui.Input.view (forwardTo address Input) updatedInput
      ]
