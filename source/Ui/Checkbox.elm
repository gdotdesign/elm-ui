module Ui.Checkbox exposing
  ( Model, Action(..), init, subscribe, update, setValue, view, toggleView
  , radioView) -- where

{-| Checkbox component with three different views.

# Model
@docs Model, Action, init, subscribe, update

# Views
@docs view, toggleView, radioView

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList, tabindex)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node)
-- import Html.Lazy

import Json.Decode as JD
import Json.Encode as JE
import Ui.Helpers.Emitter as Emitter

import Native.Uid
import Dict

import Ui

{-| Representation of a checkbox:
  - **disabled** - Whether or not the checkbox is disabled
  - **readonly** - Whether or not the checkbox is readonly
  - **value** - Whether or not the checkbox is checked
  - **uid** - The unique identifier of the checkbox
-}
type alias Model =
  { disabled : Bool
  , readonly : Bool
  , value : Bool
  , uid : String
  }

{-| Actions that a checkbox can make. -}
type Action
  = Toggle

{-| Initiaizes a checkbox with the given value.

    Checkbox.init False
-}
init : Bool -> Model
init value =
  { uid = Native.Uid.uid ()
  , disabled = False
  , readonly = False
  , value = value
  }

{-| Provides a subscription for the changes of a checkbox. -}
subscribe : (Bool -> a) -> Model -> Sub a
subscribe action model =
  Emitter.listen model.uid (Emitter.decode JD.bool False action)

{-| Updates a checkbox. -}
update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Toggle ->
      let
        value = not model.value
      in
        ({ model | value = value }, Emitter.send model.uid (JE.bool value))

{-| Sets the value of a checkbox to the given one. -}
setValue : Bool -> Model -> Model
setValue value model =
  { model | value = value }

{-| Renders a checkbox. -}
view : Model -> Html.Html Action
view model =
  {- Html.Lazy.lazy -} render model

-- Render internal.
render : Model -> Html.Html Action
render model =
  node "ui-checkbox"
    (attributes model)
    [Ui.icon "checkmark" False []]

{-| Renders a checkbox as a radio. -}
radioView : Model -> Html.Html Action
radioView model =
  {- Html.Lazy.lazy -} radioRender model

-- Render radio internal.
radioRender : Model -> Html.Html Action
radioRender model =
  node "ui-checkbox-radio"
    (attributes model)
    [ node "ui-checkbox-radio-circle" [] []
    ]

{-| Renders a checkbox as a toggle. -}
toggleView : Model -> Html.Html Action
toggleView model =
  {- Html.Lazy.lazy -} toggleRender model

-- Render toggle internal.
toggleRender : Model -> Html.Html Action
toggleRender model =
  node "ui-checkbox-toggle"
    (attributes model)
    [ node "ui-checkbox-toggle-bg" [] []
    , node "ui-checkbox-toggle-handle" [] []
    ]

-- Returns attributes for a checkbox
attributes : Model -> List (Html.Attribute Action)
attributes model =
  let
    actions =
      Ui.enabledActions model
        [ onClick Toggle
        , onKeys [ (13, Toggle)
                 , (32, Toggle)
                 ]
        ]
  in
    [ classList [ ("disabled", model.disabled)
                , ("readonly", model.readonly)
                , ("checked", model.value) ]
    ] ++ (Ui.tabIndex model) ++ actions
