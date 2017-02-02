module Ui.InplaceInput exposing
  ( Model, Msg, init, onChange, update, view, render, setValue, open, close
  , required, ctrlSave, placeholder )

{-| Inplace editing textarea / input component.

# Model
@docs Model, Msg, init, update

# DSL
@docs required, ctrlSave, placeholder

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs open, close, setValue
-}

import Html.Events.Extra exposing (onEnter, onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Attributes
import Html.Lazy

import String
import Task
import Dom

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Container
import Ui.Textarea
import Ui.Button
import Ui

import Ui.Styles.InplaceInput exposing (defaultStyle)
import Ui.Styles


{-| Represents an inplace input:
  - **required** - Whether or not to disable the save button if the value is empty
  - **disabled** - Whether or not the inplace input is disabled
  - **readonly** - Whether or not the inplace input is readonly
  - **uid** - The unique identifier of the inplace input
  - **ctrlSave** - Whether or not to save on ctrl+enter
  - **open** - Whether or not the inplace input is open
  - **value** - The value of the inplace input
  - **textarea** - The textarea model
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
  = Done (Result Dom.Error ())
  | Textarea Ui.Textarea.Msg
  | Close
  | Save
  | Edit


{-| Initializes an inplace input with the given value and palceholder.

    inplaceInput =
      Ui.InplaceInput.init ()
        |> Ui.InplaceInput.placeholder "Type here..."
-}
init : () -> Model
init _ =
  { textarea = Ui.Textarea.init ()
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , required = True
  , ctrlSave = True
  , open = False
  , value = ""
  }


{-| Sets whether or not to disable the save button if the value is empty.
-}
required : Bool -> Model -> Model
required value model =
  { model | required = value }


{-| Sets the placeholder of an inplace input.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | textarea = Ui.Textarea.placeholder value model.textarea }


{-| Sets whether or not to control key is needed to save.
-}
ctrlSave : Bool -> Model -> Model
ctrlSave value model =
  { model | ctrlSave = value }


{-| Subscribe to the changes of an inplace input.

    subscription = Ui.InplaceInput.onChange InplaceInputChanged inplaceInput
-}
onChange : (String -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenString model.uid msg


{-| Updates an inplace input.
    ( updatedInplaceInput, cmd ) = Ui.InplaceInput.update msg inplaceInput
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

    Done _ ->
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
    node
      "ui-inplace-input"
      ( [ Ui.Styles.apply defaultStyle
        , Ui.attributeList
         [ ( "disabled", model.disabled )
         , ( "readonly", model.readonly )
         ]
        ]
        |> List.concat
      ) [ content ]


{-| Opens an inplace input and focuses the textarea.
-}
open : Model -> ( Model, Cmd Msg )
open model =
  let
    ( textarea, cmd ) =
      Ui.Textarea.setValue model.value model.textarea
  in
    ( { model | open = True, textarea = textarea }
    , Cmd.batch
      [ Task.attempt Done (Dom.focus model.textarea.uid)
      , Cmd.map Textarea cmd
      ]
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
      , onKeys False [ ( 27, Close ) ]
      ]
      [ Html.map Textarea (Ui.Textarea.view model.textarea)
      , Ui.Container.view
          { compact = True
          , direction = "row"
          , align = "stretch"
          }
          []
          [ Ui.Button.view
              Save
              { disabled = disabled
              , readonly = False
              , kind = "primary"
              , size = "medium"
              , text = "Save"
              }
          , Ui.Button.view
              Close
              { disabled = False
              , readonly = False
              , kind = "secondary"
              , size = "medium"
              , text = "Close"
              }
          ]
      ]


{-| Renders the display.
-}
display : Model -> Html.Html Msg
display model =
  let
    click =
      Ui.enabledActions model [ onClick Edit ]

    attributes =
      [ Html.Attributes.attribute "placeholder" model.textarea.placeholder ]
        ++ click
  in
    node "ui-inplace-input-content" attributes [ text model.value ]


{-| Returns whether the given inplace input is empty.
-}
isEmpty : Model -> Bool
isEmpty model =
  String.isEmpty (String.trim model.textarea.value)


{-| Sets the value of an inplace input.

    ( updatedInplaceInput, cmd ) =
      Ui.InplaceInput.setValue "new value" inplaceInput
-}
setValue : String -> Model -> ( Model, Cmd Msg )
setValue value model =
  let
    ( textarea, cmd ) =
      Ui.Textarea.setValue value model.textarea
  in
    ( { model | textarea = textarea, value = value }, Cmd.map Textarea cmd )
