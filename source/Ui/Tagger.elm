module Ui.Tagger exposing
  ( Tag, Model, Msg, init, update, view, render, setValue, onCreate, onRemove
  , placeholder, removeable )

{-| Component for displaying tags and handling it's events (adding / removing).

# Model
@docs Model, Msg, Tag, init, update

# Events
@docs onCreate, onRemove

# DSL
@docs removeable, placeholder

# View
@docs view, render

# Functions
@docs setValue
-}

import String

import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.IconButton
import Ui.Container
import Ui.Icons
import Ui.Input
import Ui

import Ui.Styles.Tagger exposing (defaultStyle)
import Ui.Styles

{-| Represents a tag:
  - **id** - The identifier of the tag
  - **label** - The label to display
-}
type alias Tag =
  { label : String
  , id : String
  }


{-| Representation of a tagger component:
  - **disabled** - Whether or not the tagger is disabled
  - **readonly** - Whether or not the tagger is readonly
  - **removeable** - Whether or not tags can be removed
  - **uid** - The unique identifier of the chooser
  - **input** - The model of the input field
-}
type alias Model =
  { input : Ui.Input.Model
  , removeable : Bool
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }


{-| Actions that a tagger can make.
-}
type Msg
  = Input Ui.Input.Msg
  | Remove String
  | Create


{-| Initializes a tagger.

    tagger =
      Ui.Tagger.init ()
        |> Ui.Tagger.removeable False
        |> Ui.Tagger.placeholder "Add tag..."
-}
init : () -> Model
init _ =
  { input = Ui.Input.init ()
  , removeable = True
  , disabled = False
  , readonly = False
  , uid = Uid.uid ()
  }


{-| Sets whether or not tags can be removed.
-}
removeable : Bool -> Model -> Model
removeable value model =
  { model | removeable = value }


{-| Sets the placeholder of the input input of a tagger.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | input = Ui.Input.placeholder value model.input }


{-| Subscribe to the **create** events of a tagger.

    subscriptions = Ui.Tagger.onCreate AddTag tagger
-}
onCreate : (String -> msg) -> Model -> Sub msg
onCreate msg model =
  Emitter.listenString (model.uid ++ "-create") msg


{-| Subscribe to the **remove** events of a tagger.

    subscriptions = Ui.Tagger.onRemove RemoveTag tagger
-}
onRemove : (String -> msg) -> Model -> Sub msg
onRemove msg model =
  Emitter.listenString (model.uid ++ "-remove") msg


{-| Updates a tagger.

    ( updatedTagger, cmd ) = Ui.Tagger.update msg tagger
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Input act ->
      let
        ( input, effect ) =
          Ui.Input.update act model.input
      in
        ( { model | input = input }, Cmd.map Input effect )

    Create ->
      let
        isEmpty =
          String.trim model.input.value
            |> String.isEmpty
      in
        if isEmpty then
          ( model, Cmd.none )
        else
          ( model, Emitter.sendString (model.uid ++ "-create") model.input.value )

    Remove id ->
      ( model, Emitter.sendString (model.uid ++ "-remove") id )


{-| Lazily renders a tagger.

    Ui.Tagger.view [tag1, tag2] tagger
-}
view : List Tag -> Model -> Html.Html Msg
view tags model =
  Html.Lazy.lazy2 render tags model


{-| Renders a tagger.

    Ui.Tagger.render [tag1, tag2] tagger
-}
render : List Tag -> Model -> Html.Html Msg
render tags model =
  let
    input =
      model.input

    isEmpty =
      String.trim input.value
        |> String.isEmpty

    updatedInput =
      { input
        | disabled = model.disabled
        , readonly = model.readonly
      }

    button =
      { disabled = model.disabled || model.readonly || isEmpty
      , glyph = Ui.Icons.plus []
      , readonly = False
      , kind = "primary"
      , size = "medium"
      , side = "left"
      , text = ""
      }

    attributes =
      [ Ui.attributeList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
      , Ui.Styles.apply defaultStyle
      , actions
      ]
      |> List.concat

    actions =
      Ui.enabledActions
        model
        [ onKeys True [ ( 13, Create ) ]
        ]
  in
    node
      "ui-tagger"
      attributes
      [ Ui.Container.row
          []
          [ Html.map Input (Ui.Input.view updatedInput)
          , Ui.IconButton.view Create button
          ]
      , node
          "ui-tagger-tags"
          []
          (List.map (renderTag model) tags)
      ]


{-| Sets the value of a taggers input.

    ( updatedTagger, cmd ) = Ui.Tagger.setValue "" tagger
-}
setValue : String -> Model -> ( Model, Cmd Msg)
setValue value model =
  let
    ( input, cmd ) =
      Ui.Input.setValue value model.input
  in
    ( { model | input = input }, Cmd.map Input cmd )


{-| Renders a tag.
-}
renderTag : Model -> Tag -> Html.Html Msg
renderTag model tag =
  let
    icon =
      if model.disabled || model.readonly || not model.removeable then
        text ""
      else
        Ui.Icons.close
          ([ onClick (Remove tag.id)
           , onKeys True [ ( 13, Remove tag.id ) ]
           ]
            ++ (Ui.tabIndex model)
          )
  in
    node
      "ui-tagger-tag"
      []
      [ text tag.label
      , icon
      ]
