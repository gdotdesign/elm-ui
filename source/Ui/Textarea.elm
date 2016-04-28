module Ui.Textarea exposing (Model, Msg, init, subscribe, update, view, render, setValue, focus)

{-| Textarea which uses a mirror object to render the contents the same way,
thus creating an automatically growing textarea.

# Model
@docs Model, Msg, init, subscribe, update

# View
@docs view, render

# Functions
@docs setValue, focus
-}

import Html.Extra exposing (onEnterPreventDefault, onStop)
import Html exposing (node, textarea, text, br)
import Html.Events exposing (onInput)
import Html.Attributes
  exposing
    ( value
    , spellcheck
    , placeholder
    , classList
    , readonly
    , disabled
    , attribute
    )

import Native.Browser
import Native.Uid

import String
import Task
import List

import Ui.Helpers.Emitter as Emitter
import Ui

{-| Representation of a textarea:
  - **placeholder** - The text to display when there is no value
  - **enterAllowed** - Whether or not to allow new lines when pressing enter
  - **disabled** - Whether or not the textarea is disabled
  - **readonly** - Whether or not the textarea is readonly
  - **value** - The value
  - **uid** - The unique identifier of the textarea
-}
type alias Model =
  { placeholder : String
  , enterAllowed : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , uid : String
  }


{-| Messages that a textarea can receive.
-}
type Msg
  = Input String
  | Tasks ()
  | NoOp


{-| Initializes a textarea with a default value and a placeholder.

    model = Ui.Textarea.init "default value" "Placeholder..."
-}
init : String -> String -> Model
init value placeholder =
  { placeholder = placeholder
  , uid = Native.Uid.uid ()
  , enterAllowed = True
  , disabled = False
  , readonly = False
  , value = value
  }


{-| Subscribe for the changes of a textarea.

    ...
    subscriptions =
      \model -> Ui.Textarea.subscribe TextareaChanged model.textarea
    ...
-}
subscribe : (String -> a) -> Model -> Sub a
subscribe msg model =
  Emitter.listenString model.uid msg


{-| Updates a textarea.

    Ui.Textarea.update msg model
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Input value ->
      ( setValue value model, Emitter.sendString model.uid value )

    _ ->
      ( model, Cmd.none )


{-| Lazily renders a textarea.

    Ui.Textarea.view model
-}
view : Model -> Html.Html Msg
view model =
  render model


{-| Renders a textarea.

    Ui.Textarea.render model
-}
render : Model -> Html.Html Msg
render model =
  let
    base =
      [ placeholder model.placeholder
      , attribute "uid" model.uid
      , readonly model.readonly
      , disabled model.disabled
      , value model.value
      , spellcheck False
      ]
        ++ actions

    actions =
      Ui.enabledActions
        model
        [ onStop "select" NoOp
        , onInput Input
        ]

    attributes =
      if model.enterAllowed then
        base
      else
        base ++ [ onEnterPreventDefault NoOp ]
  in
    node
      "ui-textarea"
      ([ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
       ]
      )
      [ textarea attributes []
      , node "ui-textarea-background" [] []
      , node "ui-textarea-mirror" [] (process model.value)
      ]


{-| Sets the value of the given textarea.

    Ui.Textarea.setValue "new value" model
-}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }


{-| Focuses a textarea.

    Cmd.map Textarea (Ui.Textarea.focus model)
-}
focus : Model -> Cmd Msg
focus model =
  Task.perform Tasks Tasks (Native.Browser.focusUid model.uid)


{-| Processes the value for the mirror object.
-}
process : String -> List (Html.Html Msg)
process value =
  String.split "\n" value
    |> List.map (\data -> node "span-line" [] [ text data ])
    |> List.intersperse (br [] [])
