module Ui.Input exposing
  (Model, Msg, init, subscribe, update, view, render, setValue)

{-| Component for single line text based input (wrapper for the input HTML tag).

# Model
@docs Model, Msg, init, subscribe, update

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
    , placeholder
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
  = Input String
  | Done (Result DOM.Error ())


{-| Initializes an input with a default value and a placeholder.

    input = Ui.Input.init "value" "Placeholder..."
-}
init : String -> String -> Model
init value placeholder =
  { placeholder = placeholder
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , value = value
  , kind = "text"
  }


{-| Subscribe to the changes of an input.

    ...
    subscriptions =
      \model -> Ui.Input.subscribe InputChanged model.input
    ...
-}
subscribe : (String -> msg) -> Model -> Sub msg
subscribe msg model =
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
        [ placeholder model.placeholder
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

    Ui.Input.setValue "new value" input
-}
setValue : String -> Model -> ( Model, Cmd Msg)
setValue value model =
  let
    task =
      DOM.setValue value (DOM.idSelector model.uid)
  in
    ( { model | value = value }, Task.attempt Done task )
