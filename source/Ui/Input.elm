module Ui.Input exposing
  (Model, Msg, init, onChange, update, view, render, placeholder, setValue)

{-| Component for single line text based input (wrapper for the input HTML tag).

# Model
@docs Model, Msg, init, update

# DSL
@docs placeholder

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Events exposing (onInput)
import Html exposing (node)
import Html.Lazy
import Html.Attributes
  exposing
    ( defaultValue
    , spellcheck
    , type_
    , readonly
    , disabled
    , classList
    , attribute
    , id
    )

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid

import Task
import DOM


{-| Representation of an input:
  - **placeholder** - The text to display when there is no value
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **uid** - The unique identifier of the input
  - **kind** - The type of the input
  - **value** - The value
-}
type alias Model =
  { placeholder : String
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


{-| Initializes an input with a default value and a placeholder.

    input =
      Ui.Input.init "value"
        |> Ui.Input.placeholder "Type here..."
-}
init : String -> Model
init value =
  { placeholder = ""
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , value = value
  , kind = "text"
  }


{-| Sets the placeholder of an input.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | placeholder = value }


{-| Subscribe to the changes of an input.

    ...
    subscriptions =
      \model -> Ui.Input.onChange InputChanged model.input
    ...
-}
onChange : (String -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenString model.uid msg


{-| Updates an input.

    Ui.Input.update msg input
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Input value ->
      ( { model | value = value }, Emitter.sendString model.uid value )

    Done result ->
      let
        _ =
          case result of
            Err error -> Debug.log "Could not set value:" (toString error)
            Ok _ -> ""
      in
        ( model, Cmd.none )


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
  node
    "ui-input"
    [ classList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
    ]
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
    ]


{-| Sets the value of an input.

    (updatedInput, cmd) = Ui.Input.setValue "new value" input
-}
setValue : String -> Model -> ( Model, Cmd Msg)
setValue value model =
  let
    task =
      DOM.setValue value (DOM.idSelector model.uid)
  in
    ( { model | value = value }, Task.attempt Done task )
