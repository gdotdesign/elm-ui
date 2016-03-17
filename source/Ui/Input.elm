module Ui.Input
  (Model, Action, init, initWithAddress, update, view, setValue, focus) where

{-| Component for text based input.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs setValue, focus
-}
import Html.Attributes exposing (value, spellcheck, placeholder, type',
                                 readonly, disabled, classList, attribute)
import Html.Extra exposing (onInput)
import Html exposing (node)
import Html.Lazy

import Native.Browser
import Native.Uid

import Ext.Signal
import Effects
import Signal
import String
import Task

{-| Representation of an input:
  - **placeholder** - The text to display when there is no value
  - **valueAddress** - The address to send the changes in value
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **uid** - The unique identifier of the input
  - **kind** - The type of the input
  - **value** - The value
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address String)
  , placeholder : String
  , disabled : Bool
  , readonly : Bool
  , value : String
  , kind : String
  , uid : String
  }

{-| Actions that an input can make. -}
type Action
  = Input String
  | Tasks ()

{-| Initializes an input.

    Input.init "value"
-}
init : String -> String -> Model
init value placeholder =
  { placeholder = placeholder
  , uid = Native.Uid.uid ()
  , valueAddress = Nothing
  , disabled = False
  , readonly = False
  , value = value
  , kind = "text"
  }

{-| Initializes an input.

    Input.init (forwardTo address InputChanged) "value"
-}
initWithAddress : Signal.Address String -> String -> String -> Model
initWithAddress valueAddress value placeholder =
  let
    model = init value placeholder
  in
    { model | valueAddress = Just valueAddress }

{-| Updates an input. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Input value ->
      ( setValue value model
      , Ext.Signal.sendAsEffect model.valueAddress value Tasks )

    Tasks _ ->
      (model, Effects.none)

{-| Focuses an input if it's in the dom.

This function has a 30ms (delay) to wait for the element to appear on the page.
-}
focus : Model -> Effects.Effects Action
focus model =
  Effects.task (Native.Browser.focusTask ("[uid='" ++ model.uid ++ "']"))
  |> Effects.map Tasks

{-| Renders an input. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-input" [ classList [ ("disabled", model.disabled)
                              , ("readonly", model.readonly)
                              ]
                  ]
    [ node "input" [ placeholder model.placeholder
                   , onInput address Input
                   , value model.value
                   , spellcheck False
                   , type' model.kind
                   , readonly model.readonly
                   , disabled model.disabled
                   , attribute "uid" model.uid
                   ]
                   []
    ]

{-| Sets the value of the model. -}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }
