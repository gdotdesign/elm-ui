module Ui.InplaceInput (Model, Action, init, update, view) where

{-| Inplace editing textarea / input component.

# Model
@docs Model, Action, init, update

# View
@docs view
-}
import Html.Extra exposing (onEnter, onKeys)
import Html exposing (node, div, text)
import Html.Events exposing (onClick)
import Html.Lazy

import Signal exposing (forwardTo)
import Ext.Signal
import Effects
import String

import Native.Browser

import Ui.Container
import Ui.Button
import Ui.Textarea
import Ui

{-| Represents an inplace input:
  - **required** - Whether or not to disable the component if the value is empty
  - **disabled** - Whether or not the component is disabled
  - **readonly** - Whether or not the component is readonly
  - **ctrlSave** - Whether or not to save on ctrl+enter
  - **value** - The value of the component
  - **open** (internal) - Whether or not the component is open
  - **mailbox** (internal) - The mailbox of the textarea
  - **textarea** (internal) - The state of the textarea
-}
type alias Model =
  { mailbox : Signal.Mailbox String
  , textarea : Ui.Textarea.Model
  , valueSignal : Signal String
  , required : Bool
  , ctrlSave : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , open : Bool
  }

{-| Actions that an inplace input can make. -}
type Action
  = Textarea Ui.Textarea.Action
  | Tasks ()
  | Close
  | Save
  | Edit

{-| Initializes an inplace input with the given value. -}
init : String -> Model
init value =
  let
    mailbox = Signal.mailbox value
  in
    { valueSignal = Signal.dropRepeats mailbox.signal
    , textarea = Ui.Textarea.init value
    , mailbox = mailbox
    , disabled = False
    , readonly = False
    , required = True
    , ctrlSave = False
    , value = value
    , open = False
    }

{-| Updates an inplace input. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Save ->
      if (isEmpty model) && model.required then
        (model, Effects.none)
      else
        ( close { model | value = model.textarea.value }
        , Ext.Signal.sendAsEffect
            model.mailbox.address
            model.textarea.value
            Tasks )

    _ ->
      (update' action model, Effects.none)

-- Effectless updates
update' : Action -> Model -> Model
update' action model =
  case action of
    Textarea act ->
      { model | textarea = Ui.Textarea.update act model.textarea }

    Edit ->
      if model.disabled then
        model
      else
        open model

    Close ->
      close model

    _ ->
      model


{-| Renders an inplace input. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    content =
      if model.open && not (model.disabled || model.readonly) then
        form address model
      else
        display address model
  in
    node "ui-inplace-input" [] [content]

{-| Renders the form. -}
form : Signal.Address Action -> Model -> Html.Html
form address model =
  let
    disabled = (isEmpty model) && model.required
  in
    Ui.Container.column [ onEnter model.ctrlSave address Save
                        , onKeys address [(27, Close)]
                        ]
      [ Ui.Textarea.view (forwardTo address Textarea) model.textarea
      , Ui.Container.row []
        [ Ui.Button.view address Save { disabled = disabled
                                      , kind = "primary"
                                      , text = "Save"
                                      , size = "medium"
                                      }
        , Ui.spacer
        , Ui.Button.secondary "Close" address Close
        ]
      ]

{-| Renders the display. -}
display : Signal.Address Action -> Model -> Html.Html
display address model =
  let
    click = Ui.enabledActions model [onClick address Edit]
  in
    div click [text model.value]


{-| Returns whether the given inplace input is empty. -}
isEmpty : Model -> Bool
isEmpty model =
  String.isEmpty (String.trim model.textarea.value)

{-| Opens an inplace input. -}
open : Model -> Model
open model =
  { model | open = True
          , textarea = Ui.Textarea.focus model.textarea }

{-| Closes an inplace input. -}
close : Model -> Model
close model =
  { model | open = False }

