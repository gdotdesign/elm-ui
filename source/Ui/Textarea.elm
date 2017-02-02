module Ui.Textarea exposing
  ( Model, Msg, init, onChange, update, view, render, setValue, placeholder
  , enterAllowed, defaultValue )

{-| Textarea which uses a mirror object to render the contents the same way,
thus creating an automatically growing textarea.

# Model
@docs Model, Msg, init, update

# Events
@docs onChange

# DSL
@docs placeholder, enterAllowed, defaultValue

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Attributes exposing (spellcheck, readonly, disabled, id)
import Html.Events.Extra exposing (onEnterPreventDefault)
import Html exposing (node, textarea, text, br)
import Html.Events exposing (onInput)
import Html.Lazy

import Regex exposing (Regex)
import String
import Task
import List

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui

import Ui.Styles.Textarea exposing (defaultStyle)
import Ui.Styles

import DOM

{-| Representation of a textarea:
  - **enterAllowed** - Whether or not to allow new lines when pressing enter
  - **placeholder** - The text to display when there is no value
  - **disabled** - Whether or not the textarea is disabled
  - **readonly** - Whether or not the textarea is readonly
  - **uid** - The unique identifier of the textarea
  - **value** - The value
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
  = Done (Result DOM.Error ())
  | Input String
  | NoOp


{-| Initializes a textarea with a default value and a placeholder.

    textarea =
      Ui.Textarea.init ()
        |> Ui.Textarea.placeholder "Placeholder"
        |> Ui.Textarea.enterAllowed False
-}
init : () -> Model
init _ =
  { enterAllowed = True
  , uid = Uid.uid ()
  , placeholder = ""
  , disabled = False
  , readonly = False
  , value = ""
  }


{-| Subscribe for the changes of a textarea.

    subscriptions = Ui.Textarea.onChange TextareaChanged textarea
-}
onChange : (String -> a) -> Model -> Sub a
onChange msg model =
  Emitter.listenString model.uid msg


{-| Sets the placeholder of a textarea.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | placeholder = value }


{-| Sets whether or not pressing enter creates a new line.
-}
enterAllowed : Bool -> Model -> Model
enterAllowed value model =
  { model | enterAllowed = value }


{-| Sets the default value of a textarea.
-}
defaultValue : String -> Model -> Model
defaultValue value model =
  { model | value = value }


{-| Updates a textarea.

    ( updatedTextarea, cmd ) = Ui.Textarea.update msg textarea
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Input value ->
      ( { model | value = value }, Emitter.sendString model.uid value )

    _ ->
      ( model, Cmd.none )


{-| Lazily renders a textarea.

    Ui.Textarea.view textarea
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a textarea.

    Ui.Textarea.render textarea
-}
render : Model -> Html.Html Msg
render model =
  let
    base =
      [ Html.Attributes.placeholder model.placeholder
      , Html.Attributes.defaultValue model.value
      , readonly model.readonly
      , disabled model.disabled
      , spellcheck False
      , id model.uid
      ]
        ++ actions

    actions =
      Ui.enabledActions
        model
        [ onInput Input
        ]

    attributes =
      if model.enterAllowed then
        base
      else
        base ++ [ onEnterPreventDefault NoOp ]
  in
    node
      "ui-textarea"
      (Ui.Styles.apply defaultStyle)
      [ textarea attributes []
      , node "ui-textarea-background" [] []
      , node "ui-textarea-mirror" [] (process model.value)
      ]


{-| Sets the value of the given textarea.

    ( updatedTextarea, cmd ) = Ui.Textarea.setValue "new value" textarea
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


{-| Regexp for matching emtpy lines.
-}
spaceRegex : Regex
spaceRegex =
  Regex.regex "^\\s*$"


{-| Processes the value for the mirror object.
-}
process : String -> List (Html.Html Msg)
process value =
  let
    renderLine data =
      let
        isEmpty =
          Regex.contains spaceRegex data

        attributes =
          Ui.attributeList
            [ ("empty", isEmpty )
            ]
      in
        node "span-line" attributes [ text data ]
  in
    String.split "\n" value
      |> List.map renderLine
      |> List.intersperse (br [] [])
