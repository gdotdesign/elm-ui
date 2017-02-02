module Ui.Input exposing
  ( Model, Msg, init, onChange, update, view, render, placeholder
  , showClearIcon, setValue, kind )

{-| Component for single line text based input (wrapper for the input HTML tag).

# Model
@docs Model, Msg, init, update

# DSL
@docs placeholder, showClearIcon, kind

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Events exposing (onInput, onClick)
import Html exposing (node, text)
import Html.Lazy

import Html.Attributes
  exposing
    ( defaultValue
    , spellcheck
    , type_
    , readonly
    , disabled
    , attribute
    , id
    )

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Icons
import Ui

import Ui.Styles.Input exposing (defaultStyle)
import Ui.Styles

import Task
import DOM

{-| Representation of an input:
  - **placeholder** - The text to display when there is no value
  - **showClearIcon** - Whether or not to show the clear icon
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **uid** - The unique identifier of the input
  - **kind** - The type of the input
  - **value** - The value
-}
type alias Model =
  { placeholder : String
  , showClearIcon : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , kind : String
  , uid : String
  }


{-| Messages that an input can receive.
-}
type Msg
  = Done (Result DOM.Error ())
  | Input String
  | Clear


{-| Initializes an input with a default value and a placeholder.

    input =
      Ui.Input.init ()
        |> Ui.Input.placeholder "Type here..."
        |> Ui.Input.showClearIcon True
-}
init : () -> Model
init _ =
  { showClearIcon = False
  , placeholder = ""
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , kind = "text"
  , value = ""
  }


{-| Sets the placeholder of an input.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | placeholder = value }


{-| Sets the placeholder of an input.
-}
kind : String -> Model -> Model
kind value model =
  { model | kind = value }


{-| Subscribe to the changes of an input.

    subscription = Ui.Input.onChange InputChanged input
-}
onChange : (String -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenString model.uid msg


{-| Updates an input.

    ( updatedInput, cmd ) = Ui.Input.update msg input
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Done _ ->
      ( model, Cmd.none )

    Input value ->
      ( { model | value = value }, Emitter.sendString model.uid value )

    Clear ->
      let
        (updatedInput, cmd) =
          setValue "" model

        commands =
          Cmd.batch
            [ Emitter.sendString model.uid ""
            , cmd
            ]
      in
        ( updatedInput, commands )


{-| Lazily renders an input.

    Ui.Input.view input
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders an input.

    Ui.Input.render input
-}
render : Model -> Html.Html Msg
render model =
  let
    showClearIcon =
      not (not model.showClearIcon
           || model.disabled
           || model.readonly
           || model.value == "")

    clearIcon =
      if showClearIcon then
        Ui.Icons.close [onClick Clear]
      else
        text ""
  in
    node
      "ui-input"
      ( [ Ui.attributeList
          [ ( "clearable", showClearIcon)
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ node
          "input"
          [ Html.Attributes.placeholder model.placeholder
          , defaultValue model.value
          , readonly model.readonly
          , disabled model.disabled
          , spellcheck False
          , type_ model.kind
          , onInput Input
          , id model.uid
          ]
          []
      , clearIcon
      ]


{-| Sets the value of an input.

    (updatedInput, cmd) = Ui.Input.setValue "new value" input
-}
setValue : String -> Model -> ( Model, Cmd Msg)
setValue value model =
  let
    selector =
      DOM.idSelector model.uid

    equals =
      case DOM.getValueSync selector of
        Ok currentValue -> model.value == value && currentValue == value
        Err _ -> False
  in
    if equals then
      ( model, Cmd.none )
    else
      ( { model | value = value }
      , Task.attempt Done (DOM.setValue value selector)
      )


{-| Sets whether or not to show a clear icon for an input.
-}
showClearIcon : Bool -> Model -> Model
showClearIcon value model =
  { model | showClearIcon = value }
