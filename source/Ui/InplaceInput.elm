module Ui.InplaceInput exposing
  (Model, Msg, init, subscribe, update, view, render, setValue, open, close)

{-| Inplace editing textarea / input component.

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view, render

# Functions
@docs open, close, setValue
-}

import Html.Events.Extra exposing (onEnter, onKeys)
import Html exposing (node, div, text)
import Html.Events exposing (onClick)
import Html.Lazy
import Html.App
import Task
import Dom

import String

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Container
import Ui.Textarea
import Ui.Button
import Ui


{-| Represents an inplace input:
  - **textarea** - The textarea model
  - **required** - Whether or not to disable the save button if the value is empty
  - **disabled** - Whether or not the inplace input is disabled
  - **readonly** - Whether or not the inplace input is readonly
  - **ctrlSave** - Whether or not to save on ctrl+enter
  - **value** - The value of the inplace input
  - **open** - Whether or not the inplace input is open
  - **uid** - The unique identifier of the inplace input
-}
type alias Model =
  { textarea : Ui.Textarea.Model
  , required : Bool
  , ctrlSave : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , uid : String
  , open : Bool
  }


{-| Messages that an inplace input can recieve.
-}
type Msg
  = Textarea Ui.Textarea.Msg
  | Close
  | Save
  | Edit
  | NotFound Dom.Error
  | NoOp ()


{-| Initializes an inplace input with the given value and palceholder.

    inplaceInput = Ui.InplaceInput.init "test" "placeholder"
-}
init : String -> String -> Model
init value placholder =
  { textarea = Ui.Textarea.init value placholder
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , required = True
  , ctrlSave = True
  , value = value
  , open = False
  }


{-| Subscribe to the changes of an inplace input.

    ...
    subscriptions =
      \model ->
        Ui.InplaceInput.subscribe
          InplaceInputChanged
          model.inplaceInput
    ...
-}
subscribe : (String -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listenString model.uid msg


{-| Updates an inplace input.

    Ui.InplaceInput.update msg inplaceInput
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Textarea act ->
      let
        ( textarea, effect ) =
          Ui.Textarea.update act model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map Textarea effect )

    Save ->
      if (isEmpty model) && model.required then
        ( model, Cmd.none )
      else if model.textarea.value == model.value then
        ( close model, Cmd.none )
      else
        ( close { model | value = model.textarea.value }
        , Emitter.sendString model.uid model.textarea.value
        )

    Edit ->
      if model.disabled then
        ( model, Cmd.none )
      else
        open model

    Close ->
      ( close model, Cmd.none )

    _ ->
      ( model, Cmd.none )


{-| Lazily renders an inplace input.

    Ui.InplaceInput.view inplaceInput
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders an inplace input.

    Ui.InplaceInput.render inplaceInput
-}
render : Model -> Html.Html Msg
render model =
  let
    content =
      if model.open && not (model.disabled || model.readonly) then
        form model
      else
        display model
  in
    node "ui-inplace-input" [] [ content ]


{-| Opens an inplace input and focuses the textarea.
-}
open : Model -> ( Model, Cmd Msg )
open model =
  ( { model | open = True }
  , Task.perform NotFound NoOp (Dom.focus model.textarea.uid)
  )


{-| Closes an inplace input.
-}
close : Model -> Model
close model =
  { model | open = False }


{-| Renders the form.
-}
form : Model -> Html.Html Msg
form model =
  let
    disabled =
      (isEmpty model) && model.required
  in
    Ui.Container.column
      [ onEnter model.ctrlSave Save
      , onKeys [ ( 27, Close ) ]
      ]
      [ Html.App.map Textarea (Ui.Textarea.view model.textarea)
      , Ui.Container.row
          []
          [ Ui.Button.view
              Save
              { disabled = disabled
              , readonly = False
              , kind = "primary"
              , text = "Save"
              , size = "medium"
              }
          , Ui.spacer
          , Ui.Button.secondary "Close" Close
          ]
      ]


{-| Renders the display.
-}
display : Model -> Html.Html Msg
display model =
  let
    click =
      Ui.enabledActions model [ onClick Edit ]
  in
    div click [ text model.value ]


{-| Returns whether the given inplace input is empty.
-}
isEmpty : Model -> Bool
isEmpty model =
  String.isEmpty (String.trim model.textarea.value)


{-| Sets the value of an inplace input.

    Ui.InplaceInput.setValue "new value" inplaceInput
-}
setValue : String -> Model -> Model
setValue value model =
  { model
    | textarea = Ui.Textarea.setValue value model.textarea
    , value = value
  }
