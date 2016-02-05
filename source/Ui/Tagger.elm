module Ui.Tagger (Model, Action, init, initWithAddress, update, view) where

{-| Component for managing (add / remove) tags

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view
-}
import Signal exposing (forwardTo)
import Task exposing (Task)
import Ext.Signal
import Effects
import String

import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)
import Html.Lazy

import Ui.IconButton
import Ui.Container
import Ui.Input
import Ui

{-| Representation of a tagger component:
  - **failAddress** - The address to send failure messages to
  - **label** - The function to generate label from a tag
  - **removeable** - Whether or not a tag can be removed
  - **disabled** - Whether or not the tagger is disabled
  - **readonly** - Whether or not the tagger is readonly
  - **id** - The function to get the id of a tag
  - **remove** - The Task to remove a tag
  - **create** - The Task to create a tag
  - **tags** - The list of tags
  - **input** (interal) - The model of the input field
-}
type alias Model tag id err =
  { create : String -> List tag -> Task err tag
  , failAddress : Maybe (Signal.Address err)
  , remove : tag -> Task err tag
  , input : Ui.Input.Model
  , label : tag -> String
  , tags : List tag
  , removeable : Bool
  , id : tag -> id
  , disabled : Bool
  , readonly : Bool
  }

{-| Actions that a tagger can make. -}
type Action tag err
  = Created (Result err tag)
  | Removed (Result err tag)
  | Input Ui.Input.Action
  | Remove tag
  | Tasks ()
  | Create

{-| Initializes a tagger.

    Tagger.init [tag1, tag2] "Add a tag..." .label .id createTask removeTask
-}
init : List tag
     -> String
     -> (tag -> String)
     -> (tag -> id)
     -> (String -> List tag -> Task err tag)
     -> (tag -> Task err tag)
     -> Model tag id err
init tags placeholder label id create remove =
  { input = Ui.Input.init "" placeholder
  , failAddress = Nothing
  , removeable = True
  , disabled = False
  , readonly = False
  , create = create
  , remove = remove
  , label = label
  , tags = tags
  , id = id
  }

{-| Initializes a tagger with a faliure address.

    Tagger.init
      (forwardTo address TagActionFailed)
      [tag1, tag2]
      "Add a tag..."
      .label
      .id
      createTask
      removeTask
-}
initWithAddress : Signal.Address err
                -> List tag
                -> String
                -> (tag -> String)
                -> (tag -> id)
                -> (String -> List tag -> Task err tag)
                -> (tag -> Task err tag)
                -> Model tag id err
initWithAddress failAddress tags placeholder label id create remove =
  let
    model = init tags placeholder label id create remove
  in
    { model | failAddress = Just failAddress }

{-| Updates a tagger. -}
update : Action tag err
       -> Model tag id err
       -> (Model tag id err, Effects.Effects (Action tag err))
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
            model.create model.input.value model.tags
            |> Task.toResult
            |> Effects.task
            |> Effects.map Created
      in
        (model, effect)

    Created (Ok tag) ->
      let
        (input, inputEffect) = Ui.Input.setValue "" model.input
      in
        ({ model | tags = tag :: model.tags
                 , input = input }, Effects.map Input inputEffect)

    Created (Err err) ->
      (model, failMessageEffect err model)

    Remove tag ->
      let
        effect =
          model.remove tag
          |> Task.toResult
          |> Effects.task
          |> Effects.map Removed
      in
        (model, effect)

    Removed (Ok removedtag) ->
      let
        id = model.id removedtag
        tags = List.filter (\tag -> (model.id tag) /= id) model.tags
      in
        ({ model | tags = tags }, Effects.none)

    Removed (Err err) ->
      (model, failMessageEffect err model)

    Tasks _ ->
      (model, Effects.none)

{-| Renders a tagger. -}
view: Signal.Address (Action tag err) -> Model tag id err -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Render internal. -}
render: Signal.Address (Action tag err) -> Model tag id err -> Html.Html
render address model =
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
      classList [ ( "disabled", model.disabled )
                , ( "readonly", model.readonly )
                ]

    actions =
      Ui.enabledActions model
        [ onKeys address [ ( 13, Create )
                         ]
        ]
  in
    node "ui-tagger" (classes :: actions)
      [ Ui.Container.row
        []
        [ Ui.Input.view (forwardTo address Input) updatedInput
        , Ui.IconButton.view address Create button
        ]
      , node "ui-tagger-tags"
        []
        (List.map (rendertag address model) model.tags)
      ]

{-| Returns a failure message as an Effect. -}
failMessageEffect : err
                  -> Model tag id err
                  -> Effects.Effects (Action tag err)
failMessageEffect message model =
  Ext.Signal.sendAsEffect model.failAddress message Tasks

{-| Renders a tag. -}
rendertag : Signal.Address (Action tag err)
           -> Model tag id err
           -> tag
           -> Html.Html
rendertag address model tag =
  let
    label =
      model.label tag

    icon =
      if (model.disabled || model.readonly) && model.removeable then
        text ""
      else
        Ui.icon "android-close" True [ onClick address (Remove tag)]
  in
    node "ui-tagger-tag" []
      [ text label
      , icon
      ]
