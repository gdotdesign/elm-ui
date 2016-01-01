module Ui.Textarea (Model, Action, init, update, view, setValue, focus) where

{-| Autogrow textarea, using a mirror object to render the contents the same way,
thus creating an automatically growing textarea.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue, focus
-}
import Html.Attributes exposing (value, spellcheck, placeholder, classList, readonly, disabled)
import Html.Extra exposing (onEnterPreventDefault, onInput, onStop)
import Html exposing (node, textarea, text, br)
import Html.Events exposing (onFocus)
import Html.Lazy
import Native.Browser
import String
import List

import Ui

{-| Representation of a textarea:
  - **placeholder** - The text to display when there is no value
  - **value** - The value
  - **enterAllowed** - Whether or not to allow new lines when pressing enter
  - **disabled** - Whether or not the component is disabled
  - **readonly** - Whether or not the component is readonly
-}
type alias Model =
  { placeholder : String
  , value : String
  , enterAllowed : Bool
  , focusNext : Bool
  , disabled : Bool
  , readonly : Bool
  }

{-| Actions a textrea can make. -}
type Action
  = Input String
  | Nothing
  | Focus

{-| Initializes a textraea with the given value.

    Ui.Textrea.init "value"
-}
init : String -> Model
init value =
  { placeholder = ""
  , value = value
  , enterAllowed = True
  , focusNext = False
  , disabled = False
  , readonly = False
  }

{-| Updates a textrea. -}
update : Action -> Model -> Model
update action model =
  case action of
    Input value ->
      setValue value model

    Focus ->
      { model | focusNext = False }

    _ ->
      model

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
        [ onStop "select" address Nothing
        , onInput address Input
        ]

    attributes =
      if model.enterAllowed then
        base
      else
        base ++ [onEnterPreventDefault address Nothing]

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
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }

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

