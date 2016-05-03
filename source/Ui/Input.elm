module Ui.Input exposing
  (Model, Msg, init, subscribe, update, view, render, setValue, focus)

{-| Component for single line text based input (wrapper for the input HTML tag).

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view, render

# Functions
@docs setValue, focus
-}

-- where

import Html.Events exposing (onInput)
import Html exposing (node)
import Html.Attributes
  exposing
    ( value
    , spellcheck
    , placeholder
    , type'
    , readonly
    , disabled
    , classList
    , attribute
    )

import Native.Browser
import Native.Uid

import Ui.Helpers.Emitter as Emitter

import String
import Task


{-| Representation of an input:
  - **placeholder** - The text to display when there is no value
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **value** - The value
  - **kind** - The type of the input
  - **uid** - The unique identifier of the input
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
  | Tasks ()


{-| Initializes an input with a default value and a placeholder.

    input = Ui.Input.init "value" "Placeholder..."
-}
init : String -> String -> Model
init value placeholder =
  { placeholder = placeholder
  , uid = Native.Uid.uid ()
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
      ( setValue value model, Emitter.sendString model.uid value )

    Tasks _ ->
      ( model, Cmd.none )


{-| Lazily renders an input.

    Ui.Input.view input
-}
view : Model -> Html.Html Msg
view model =
  render model


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
        , attribute "uid" model.uid
        , readonly model.readonly
        , disabled model.disabled
        , value model.value
        , spellcheck False
        , type' model.kind
        , onInput Input
        ]
        []
    ]


{-| Sets the value of an input.

    Ui.Input.setValue "new value" input
-}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }


{-| Focuses an input.

    Cmd.map Input (Ui.Input.focus input)
-}
focus : Model -> Cmd Msg
focus model =
  Task.perform Tasks Tasks (Native.Browser.focusUid model.uid)
