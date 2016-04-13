module Ui.SearchInput
  (Model, Action, init, initWithAddress, update, view, setValue) where

{-| A input component for handling searches. The component will send the
current value of the input when it has settled after the given timeout.

# Model
@docs Model, Action, init, initWithAddress, update, setValue

# View
@docs view
-}
import Html.Attributes exposing (classList)
import Html exposing (node)
import Html.Lazy

import Signal exposing (forwardTo)
import Time exposing (Time)
import Ext.Signal
import Ext.Date
import Effects
import Task
import Date

import Ui.Input
import Ui

{-| Representation of a search input:
  - **timeout** - The duration after which the input is considered settled
  - **valueAddress** - The address to send the messages to
  - **disabled** - Whether or not the input is disabled
  - **readonly** - Whether or not the input is readonly
  - **value** - The current value of the input
  - **timestamp** (internal) - The timestamp of the last edit
  - **input** (internal) - The model of the input component
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address String)
  , input : Ui.Input.Model
  , timestamp : Time
  , disabled : Bool
  , readonly : Bool
  , value : String
  , timeout : Time
  }

{-| Actions that a search input can make. -}
type Action
  = Input Ui.Input.Action
  | Update Time
  | Tasks ()

{-| Initializes a search input with the given timeout.

    SearchInput.init 1000
-}
init : Time -> Model
init timeout =
  { input = Ui.Input.init "" "Search..."
  , valueAddress = Nothing
  , timeout = timeout
  , disabled = False
  , readonly = False
  , timestamp = 0
  , value = ""
  }

{-| Initializes a search input with the given address and timeout.

    SearchInput.initWithAddress (forwardTo address SearchInputChanged) 1000
-}
initWithAddress : Signal.Address String -> Time -> Model
initWithAddress valueAddress timeout =
  let
    model = init timeout
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a search input. -}
update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Update time ->
      let
        value = model.input.value
      in
        if time == (model.timestamp + model.timeout) &&
          model.value /= value then
          ({ model | value = value }
          , Ext.Signal.sendAsEffect model.valueAddress value Tasks)
        else
          (model, Effects.none)

    Input act ->
      let
        justNow = Ext.Date.nowTime Nothing

        (input, effect2) = Ui.Input.update act model.input

        updatedModel =
          { model | input = input
                  , timestamp = justNow }
        effect =
          Task.andThen
            (Task.sleep model.timeout)
            (\_ -> Task.succeed (Update (justNow + model.timeout)))
            |> Effects.task
      in
        (updatedModel, effect)

    Tasks _ -> (model, Effects.none)

{-| Renders a search input. -}
view: Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render: Signal.Address Action -> Model -> Html.Html
render address {input, disabled, readonly} =
  let
    updatedInput = { input | disabled = disabled
                           , readonly = readonly }
  in
    node "ui-search-input" []
      [ Ui.icon "search" False []
      , Ui.Input.view (forwardTo address Input) updatedInput
      ]

{-| Sets the value of the model. -}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value, input = Ui.Input.setValue value model.input }
