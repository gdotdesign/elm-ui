module Ui.Textarea
  (Model, Action, init, initWithAddress, update, view, setValue, focus) where

{-| Autogrow textarea, using a mirror object to render the contents the same
way, thus creating an automatically growing textarea.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs setValue, focus
-}
import Html.Attributes exposing (value, spellcheck, placeholder, classList,
                                 readonly, disabled)
import Html.Extra exposing (onEnterPreventDefault, onInput, onStop)
import Html exposing (node, textarea, text, br)
import Html.Events exposing (onFocus)
import Html.Lazy

import Native.Browser
import Ext.Signal
import Effects
import Signal
import String
import List

import Ui

{-| Representation of a textarea:
  - **enterAllowed** - Whether or not to allow new lines when pressing enter
  - **placeholder** - The text to display when there is no value
  - **valueAddress** - The address to send the changes in value
  - **disabled** - Whether or not the textarea is disabled
  - **readonly** - Whether or not the textarea is readonly
  - **value** - The value
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address String)
  , placeholder : String
  , enterAllowed : Bool
  , focusNext : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  }

{-| Actions a textrea can make. -}
type Action
  = Input String
  | Tasks ()
  | NoOp
  | Focus


{-| Initializes a textraea with the given value.

    Ui.Textrea.init "value"
-}
init : String -> Model
init value =
  { valueAddress = Nothing
  , enterAllowed = True
  , focusNext = False
  , placeholder = ""
  , disabled = False
  , readonly = False
  , value = value
  }

{-| Initializes a textraea with the given value and address to send the changes
in value to.

    Ui.Textrea.init (forwardTo address TextareaChanged) "value"
-}
initWithAddress : Signal.Address String -> String -> Model
initWithAddress valueAddress value =
  { valueAddress = Just valueAddress
  , enterAllowed = True
  , focusNext = False
  , placeholder = ""
  , disabled = False
  , readonly = False
  , value = value
  }

{-| Updates a textrea. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Input value ->
      setValue value model

    Focus ->
      ({ model | focusNext = False }, Effects.none)

    _ ->
      (model, Effects.none)

{-| Renders a textarea. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    base =
      [ placeholder model.placeholder
      , value model.value
      , onFocus address Focus
      , readonly model.readonly
      , disabled model.disabled
      , spellcheck False ] ++ actions

    actions =
      Ui.enabledActions model
        [ onStop "select" address NoOp
        , onInput address Input
        ]

    attributes =
      if model.enterAllowed then
        base
      else
        base ++ [onEnterPreventDefault address NoOp]

    textarea' =
      if model.focusNext then
        Native.Browser.focusEnd (textarea attributes [])
      else
        textarea attributes []
  in
    node "ui-textarea" ([classList [ ("disabled", model.disabled)
                                   , ("readonly", model.readonly)
                                   ]])
      [ textarea'
      , node "ui-textarea-background" [] []
      , node "ui-textarea-mirror" [] (process model.value)
      ]

{-| Sets the value of the given textarea. -}
setValue : String -> Model -> (Model, Effects.Effects Action)
setValue value model =
  let
    updatedModel =
      { model | value = value }

    effect =
      Maybe.map (sendValue value) model.valueAddress
      |> Maybe.withDefault Effects.none
  in
    (updatedModel, effect)

-- Sends the models value to the given address
sendValue : String -> Signal.Address String -> Effects.Effects Action
sendValue value address =
  Ext.Signal.sendAsEffect address value Tasks

{-| Focuses the textarea. -}
focus : Model -> Model
focus model =
  { model | focusNext = True }

{-| Processes the value for the mirror object. -}
process : String -> List Html.Html
process value =
  String.split "\n" value
    |> List.map (\data -> node "span-line" [] [text data])
    |> List.intersperse (br [] [])

