module Ui.Tagger where

import Signal exposing (forwardTo)
import Task exposing (Task)
import Ext.Signal
import Effects
import String

import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)

import Ui.IconButton
import Ui.Container
import Ui.Input
import Ui

type alias Model item id err =
  { create : String -> List item -> Task err item
  , remove : item -> Task err item
  , failAddress : Maybe (Signal.Address err)
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
  | Removed (Result err item)
  | Remove item
  | Tasks ()

init : List item
     -> String
     -> (item -> String)
     -> (item -> id)
     -> (String -> List item -> Task err item)
     -> (item -> Task err item)
     -> Model item id err
init items placeholder label id create remove =
  { input = Ui.Input.init "" placeholder
  , failAddress = Nothing
  , removeable = True
  , disabled = False
  , readonly = False
  , create = create
  , remove = remove
  , label = label
  , items = items
  , id = id
  }

initWithAddress : Signal.Address err
                -> List item
                -> String
                -> (item -> String)
                -> (item -> id)
                -> (String -> List item -> Task err item)
                -> (item -> Task err item)
                -> Model item id err
initWithAddress failAddress items placeholder label id create remove =
  let
    model = init items placeholder label id create remove
  in
    { model | failAddress = Just failAddress }

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

    Create ->
      let
        value = String.trim model.input.value

        effect =
          if String.isEmpty value then
            Effects.none
          else
            model.create model.input.value model.items
            |> Task.toResult
            |> Effects.task
            |> Effects.map Created
      in
        (model, effect)

    Created (Ok item) ->
      let
        (input, inputEffect) = Ui.Input.setValue "" model.input
      in
        ({ model | items = item :: model.items
                 , input = input }, Effects.map Input inputEffect)

    Created (Err err) ->
      (model, failMessageEffect err model)

    Remove item ->
      let
        effect =
          model.remove item
          |> Task.toResult
          |> Effects.task
          |> Effects.map Removed
      in
        (model, effect)

    Removed (Ok removedItem) ->
      let
        id = model.id removedItem
        items = List.filter (\item -> (model.id item) /= id) model.items
      in
        ({ model | items = items }, Effects.none)

    Removed (Err err) ->
      (model, failMessageEffect err model)

    Tasks _ ->
      (model, Effects.none)

view: Signal.Address (Action item err) -> Model item id err -> Html.Html
view address model =
  let
    input =
      model.input

    updatedInput =
      { input | disabled = model.disabled
              , readonly = model.readonly }

    button =
      { disabled = model.disabled || model.readonly
      , kind = "primary"
      , size = "medium"
      , glyph = "plus"
      , side = "left"
      , text = ""
      }

    classes =
      classList [ ("disabled", model.disabled)
                , ("readonly", model.readonly)
                ]

    actions =
      Ui.enabledActions model
        [ onKeys address [ (13, Create)
                         ]
        ]
  in
    node "ui-tagger" (classes :: actions)
      [ Ui.Container.row []
        [ Ui.Input.view (forwardTo address Input) updatedInput
        , Ui.IconButton.view address Create button
        ]
      , node "ui-tagger-tags" []
        (List.map (renderItem address model) model.items)
      ]

failMessageEffect : err
                  -> Model item id err
                  -> Effects.Effects (Action item err)
failMessageEffect message model =
  Ext.Signal.sendAsEffect model.failAddress message Tasks

renderItem : Signal.Address (Action item err)
           -> Model item id err
           -> item
           -> Html.Html
renderItem address model item =
  let
    label =
      model.label item

    icon =
      if (model.disabled || model.readonly) && model.removeable then
        text ""
      else
        Ui.icon "android-close" True [ onClick address (Remove item)]
  in
    node "ui-tagger-tag" []
      [ text label
      , icon
      ]
