module Ui.InplaceInput
  (Model, Action, init, update, view) where

{-| Inplace editing textarea / input component.

# Model
@docs Model, Action, init, update

# View
@docs view
-}
import Html exposing (node, textarea, div, text, button)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Html.Extra exposing (onEnter)
import Signal exposing (forwardTo)
import String

import Native.Browser

import Ui.Container
import Ui.Button
import Ui.Textarea
import Ui

import Debug exposing (log)

{-| Represents an inplace input:
  - **ctrlSave** - Whether or not to save on ctrl+enter
  - **required** - Whether or not to disable the component if the value is empty
  - **disabled** - Whether or not the component is disabled
  - **value** - The value of the component
  - **textarea** (internal) - The state of the textarea
  - **open** (internal) - Whether the component is open or not
-}
type alias Model =
  { open : Bool
  , required : Bool
  , ctrlSave : Bool
  , disabled : Bool
  , value : String
  , textarea : Ui.Textarea.Model
  }

{-| Actions that an inplace input can make. -}
type Action
  = Edit
  | Textarea Ui.Textarea.Action
  | Save
  | Nothing
  | Close

{-| Initializes an inplace input with the given value. -}
init : String -> Model
init value =
  { required = True
  , open = False
  , ctrlSave = True
  , disabled = False
  , value = value
  , textarea = Ui.Textarea.init value
  }

{-| Updates an inplace input. -}
update: Action -> Model -> Model
update action model =
  case action of
    Textarea act ->
      { model | textarea = Ui.Textarea.update act model.textarea }

    Edit ->
      if model.disabled then
        model
      else open model

    Close ->
      close model

    Save ->
      if  (isEmpty model) && model.required then
        model
      else
        close { model | value = model.textarea.value }

    _ -> model

{-| Renders an inplace input. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    content =
      case model.open of
        True -> form address model
        False -> display address model
  in
    node "ui-inplace-input" [] [content]

{-| Renders the form. -}
form : Signal.Address Action -> Model -> Html.Html
form address model =
  let
    disabled = (isEmpty model) && model.required
  in
    Ui.Container.view { align = "stretch"
                      , direction = "column"
                      , compact = False
                      } [onEnter model.ctrlSave address Save]
      [ Ui.Textarea.view (forwardTo address Textarea) model.textarea
      , Ui.Container.view { align = "stretch"
                          , direction = "row"
                          , compact = False
                          } []
        [ Ui.Button.view address Save { disabled = disabled, kind = "primary", text = "Save" }
        , Ui.spacer
        , Ui.Button.view address Close { disabled = False, kind = "secondary", text = "Close" }
        ]
      ]

{-| Renders the display. -}
display : Signal.Address Action -> Model -> Html.Html
display address model =
  div [onClick address Edit] [text model.value]


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

