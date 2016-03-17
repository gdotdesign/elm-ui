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
                                 readonly, disabled, attribute)
import Html.Extra exposing (onEnterPreventDefault, onInput, onStop)
import Html exposing (node, textarea, text, br)
import Html.Lazy

import Native.Browser
import Native.Uid

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
  - **uid** - The unique identifier of the textarea
  - **value** - The value
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address String)
  , placeholder : String
  , enterAllowed : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , uid : String
  }

{-| Actions a textrea can make. -}
type Action
  = Input String
  | Tasks ()
  | NoOp


{-| Initializes a textraea with the given value.

    Ui.Textrea.init "value"
-}
init : String -> Model
init value =
  { uid = Native.Uid.uid ()
  , valueAddress = Nothing
  , enterAllowed = True
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
  , uid = Native.Uid.uid ()
  , enterAllowed = True
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
      |> sendValue

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
      , readonly model.readonly
      , disabled model.disabled
      , attribute "uid" model.uid
      , spellcheck False
      ] ++ actions

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
  in
    node "ui-textarea" ([classList [ ("disabled", model.disabled)
                                   , ("readonly", model.readonly)
                                   ]])
      [ textarea attributes []
      , node "ui-textarea-background" [] []
      , node "ui-textarea-mirror" [] (process model.value)
      ]

{-| Sets the value of the given textarea. -}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }

{-| Sends the value to the the valueAddress. -}
sendValue : Model -> (Model, Effects.Effects Action)
sendValue model =
  (model, Ext.Signal.sendAsEffect model.valueAddress model.value Tasks)

{-| Focuses the textarea. -}
focus : Model -> Effects.Effects Action
focus model =
  Effects.task (Native.Browser.focusTask ("[uid='" ++ model.uid ++ "']"))
  |> Effects.map Tasks

{-| Processes the value for the mirror object. -}
process : String -> List Html.Html
process value =
  String.split "\n" value
    |> List.map (\data -> node "span-line" [] [text data])
    |> List.intersperse (br [] [])

