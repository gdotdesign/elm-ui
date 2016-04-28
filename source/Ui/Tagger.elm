module Ui.Tagger exposing (Model, Msg, init, update, view)

{-| Component for managing (add / remove) tags

# Model
@docs Model, Msg, init, update

# View
@docs view
-}

-- where

import Task exposing (Task)
import String

import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)
import Html.App

import Native.Uid

import Ui.Helpers.Emitter as Emitter
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
  , remove : tag -> Task err tag
  , input : Ui.Input.Model
  , label : tag -> String
  , tags : List tag
  , removeable : Bool
  , id : tag -> id
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }

{-| Actions that a tagger can make. -}
type Msg tag err
  = Created tag
  | Removed tag
  | Error err
  | Input Ui.Input.Msg
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
  , removeable = True
  , uid = Native.Uid.uid ()
  , disabled = False
  , readonly = False
  , create = create
  , remove = remove
  , label = label
  , tags = tags
  , id = id
  }

{-| Updates a tagger. -}
update : Msg tag err
       -> Model tag id err
       -> (Model tag id err, Cmd (Msg tag err))
update action model =
  case action of
    Input act ->
      let
        (input, effect) = Ui.Input.update act model.input
      in
        ({ model | input = input }, Cmd.map Input effect)

    Create ->
      let
        value = String.trim model.input.value

        effect =
          if String.isEmpty value then
            Cmd.none
          else
            performCreateTask model
      in
        (model, effect)

    Created (Ok tag) ->
      ({ model | tags = tag :: model.tags
               , input = Ui.Input.setValue "" model.input }, Cmd.none)

    Remove tag ->
      let
        effect =
          performRemoveTask tag model
      in
        (model, effect)

    Removed (Ok removedtag) ->
      let
        id = model.id removedtag
        tags = List.filter (\tag -> (model.id tag) /= id) model.tags
      in
        ({ model | tags = tags }, Cmd.none)

    Error err ->
      (model, Emitter.send model.uid err)

    Tasks _ ->
      (model, Cmd.none)

performRemoveTask tag model =
  Task.perform Removed Error (model.remove tag)

performCreateTask model =
  let
    task = model.create model.input.value model.tags
  in
    Task.perform Created Error task

{-| Renders a tagger. -}
view: Model tag id err -> Html.Html (Msg tag err)
view model =
  render model

{-| Render internal. -}
render: Model tag id err -> Html.Html (Msg tag err)
render model =
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
        [ onKeys [ ( 13, Create )
                 ]
        ]
  in
    node "ui-tagger" (classes :: actions)
      [ Ui.Container.row
        []
        [ Html.App.map Input (Ui.Input.view updatedInput)
        , Ui.IconButton.view Create button
        ]
      , node "ui-tagger-tags"
        []
        (List.map (rendertag model) model.tags)
      ]

{-| Renders a tag. -}
rendertag : Model tag id err
           -> tag
           -> Html.Html (Msg tag err)
rendertag model tag =
  let
    label =
      model.label tag

    icon =
      if (model.disabled || model.readonly) && model.removeable then
        text ""
      else
        Ui.icon
          "android-close"
          True
          ([ onClick (Remove tag)
           , onKeys [ (13, Remove tag) ]
           ] ++ (Ui.tabIndex model))
  in
    node "ui-tagger-tag" []
      [ text label
      , icon
      ]
