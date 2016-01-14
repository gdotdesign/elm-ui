module Ui.Checkbox
  ( Model, Action(..), init, initWithAddress, update, setValue, view, toggleView
  , radioView) where

{-| Checkbox component with three different views.

# Model
@docs Model, Action, init, initWithAddress, update

# Views
@docs view, toggleView, radioView

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList, tabindex)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ext.Signal
import Effects
import Dict

import Ui

{-| Representation of a checkbox:
  - **valueAddress** - The address to send the changes in the value to
  - **disabled** - Whether or not the checkbox is disabled
  - **readonly** - Whether or not the checkbox is readonly
  - **value** - Whether or not the checkbox is checked
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Bool)
  , disabled : Bool
  , readonly : Bool
  , value : Bool
  }

{-| Actions that a checkbox can make. -}
type Action
  = Tasks ()
  | Toggle

{-| Initiaizes a checkbox with the given value.

    Checkbox.init False
-}
init : Bool -> Signal.Address Bool -> Model
init value valueAddress =
  { valueAddress = Nothing
  , disabled = False
  , readonly = False
  , value = value
  }


{-| Initiaizes a checkbox with the given value and value signal.

    Checkbox.init (forwardTo address CheckboxChanged) False
-}
initWithAddress : Bool -> Signal.Address Bool -> Model
initWithAddress value valueAddress =
  { valueAddress = Just valueAddress
  , disabled = False
  , readonly = False
  , value = value
  }

{-| Updates a checkbox. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Toggle ->
      let
        value = not model.value
      in
        ({ model | value = value }
         , Ext.Signal.sendAsEffect model.valueAddress value Tasks)

    Tasks _ ->
      (model, Effects.none)

{-| Sets the value of a checkbox to the given one. -}
setValue : Bool -> Model -> Model
setValue value model =
  { model | value = value }

{-| Renders a checkbox. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-checkbox"
    (attributes address model)
    [Ui.icon "checkmark" False []]

{-| Renders a checkbox as a radio. -}
radioView : Signal.Address Action -> Model -> Html.Html
radioView address model =
  Html.Lazy.lazy2 radioRender address model

-- Render radio internal.
radioRender : Signal.Address Action -> Model -> Html.Html
radioRender address model =
  node "ui-checkbox-radio"
    (attributes address model)
    [ node "ui-checkbox-radio-circle" [] []
    ]

{-| Renders a checkbox as a toggle. -}
toggleView : Signal.Address Action -> Model -> Html.Html
toggleView address model =
  Html.Lazy.lazy2 toggleRender address model

-- Render toggle internal.
toggleRender : Signal.Address Action -> Model -> Html.Html
toggleRender address model =
  node "ui-checkbox-toggle"
    (attributes address model)
    [ node "ui-checkbox-toggle-bg" [] []
    , node "ui-checkbox-toggle-handle" [] []
    ]

-- Returns attributes for a checkbox
attributes : Signal.Address Action -> Model -> List Html.Attribute
attributes address model =
  let
    actions =
      Ui.enabledActions model
        [ onClick address Toggle
        , onKeys address [ (13, Toggle)
                         , (32, Toggle)
                         ]
        ]
  in
    [ classList [ ("disabled", model.disabled)
                , ("readonly", model.readonly)
                , ("checked", model.value) ]
    ] ++ (Ui.tabIndex model) ++ actions
