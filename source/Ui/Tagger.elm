module Ui.Tagger where

import Signal exposing (forwardTo)
import Task exposing (Task)
import Effects

import Html.Extra exposing (onKeys)
import Html exposing (node, text)

import Ui.Input
import Ui

type alias Model item id err =
  { removeAddress : Maybe (Signal.Address id)
  , failAddress : Maybe (Signal.Address err)
  , create : String -> List item -> Task Effects.Never (Result err item)
  , input : Ui.Input.Model
  , label : item -> String
  , items : List item
  , removeable : Bool
  , id : item -> id
  , disabled : Bool
  , readonly : Bool
  }

type Action item err
  = Input Ui.Input.Action
  | Created (Result err item)
  | Create
  | Tasks ()

init : List item
     -> (item -> String)
     -> (item -> id)
     -> (String -> List item -> Task Effects.Never (Result err item))
     -> Model item id err
init items label id create =
  { input = Ui.Input.init ""
  , removeAddress = Nothing
  , failAddress = Nothing
  , removeable = True
  , disabled = False
  , readonly = False
  , create = create
  , label = label
  , items = items
  , id = id
  }

initWithAddress : Signal.Address id
                -> Signal.Address err
                -> List item
                -> (item -> String)
                -> (item -> id)
                -> (String -> List item -> Task Effects.Never (Result err item))
                -> Model item id err
initWithAddress removeAddress failAddress items label id create =
  let
    model = init items label id create
  in
    { model | removeAddress = Just removeAddress
            , failAddress = Just failAddress }

update : Action item err
       -> Model item id err
       -> (Model item id err, Effects.Effects (Action item err))
update action model =
  case action of
    Input act ->
      let
        (input, effect) = Ui.Input.update act model.input
      in
        ({ model | input = input }, Effects.map Input effect)

    Created (Ok item) ->
      let
        (input, inputEffect) = Ui.Input.setValue "" model.input
      in
        ({ model | items = item :: model.items
                 , input = input }, Effects.map Input inputEffect)

    Created (Err err) ->
      -- Send fail signal
      (model, Effects.none)

    Create ->
      let
        effect =
          model.create model.input.value model.items
          |> Effects.task
          |> Effects.map Created
      in
        (model, effect)

    Tasks _ ->
      (model, Effects.none)

view: Signal.Address (Action item err) -> Model item id err -> Html.Html
view address model =
  let
    actions =
      Ui.enabledActions model
        [ onKeys address [ (13, Create)
                         ]
        ]
  in
    node "ui-tagger" actions
      [ Ui.Input.view (forwardTo address Input) model.input
      , node "ui-tagger-tags" []
        (List.map (renderItem address model) model.items)
      ]

renderItem : Signal.Address (Action item err)
           -> Model item id err
           -> item
           -> Html.Html
renderItem address model item =
  let
    label = model.label item
  in
    node "ui-tagger-tag" [] [text label]
