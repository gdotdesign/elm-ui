module Ui.Checkbox exposing
  ( Model, Msg, init, subscribe, update, view, render, viewToggle
  , renderToggle, viewRadio, renderRadio, setValue )

{-| Checkbox component with three different views.

# Model
@docs Model, Msg, init, subscribe, update

# Views
@docs view, render

# View Variations
@docs viewRadio, viewToggle, renderRadio, renderToggle

# Functions
@docs setValue
-}

import Html.Attributes exposing (classList)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Lazy

import Task
import Dict

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
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


{-| Messages that a checkbox can receive.
-}
type Msg
  = Toggle


{-| Initiaizes a checkbox with the given value.

    checkbox = Ui.Checkbox.init False
-}
init : Bool -> Model
init value =
  { uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , value = value
  }


{-| Subscribe to the changes of a checkbox.

    Ui.Calendar.subscribe CheckboxChanged checkbox
-}
subscribe : (Bool -> a) -> Model -> Sub a
subscribe msg model =
  Emitter.listenBool model.uid msg


{-| Updates a checkbox.

    Ui.Checkbox.update msg checkbox
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Toggle ->
      let
        value =
          not model.value
      in
        ( { model | value = value }, Emitter.sendBool model.uid value )


{-| Lazily renders a checkbox.

    Ui.Checkbox.view checkbox
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a checkbox.

    Ui.Checkbox.render checkbox
-}
render : Model -> Html.Html Msg
render model =
  node
    "ui-checkbox"
    (attributes model)
    [ Ui.icon "checkmark" False [] ]


{-| Lazily renders a checkbox as a radio.

    Ui.Checkbox.viewRadio checkbox
-}
viewRadio : Model -> Html.Html Msg
viewRadio model =
  Html.Lazy.lazy renderRadio model


{-| Renders a checkbox as a radio.

    Ui.Checkbox.renderRadio checkbox
-}
renderRadio : Model -> Html.Html Msg
renderRadio model =
  node
    "ui-checkbox-radio"
    (attributes model)
    [ node "ui-checkbox-radio-circle" [] []
    ]


{-| Lazily renders a checkbox as a toggle.

    Ui.Checkbox.viewToggle checkbox
-}
viewToggle : Model -> Html.Html Msg
viewToggle model =
  Html.Lazy.lazy renderToggle model


{-| Renders a checkbox as a toggle.

    Ui.Checkbox.renderToggle checkbox
-}
renderToggle : Model -> Html.Html Msg
renderToggle model =
  node
    "ui-checkbox-toggle"
    (attributes model)
    [ node "ui-checkbox-toggle-bg" [] []
    , node "ui-checkbox-toggle-handle" [] []
    ]


{-| Sets the value of a checkbox to the given one.

    Ui.Checkbox.setValue False checkbox
-}
setValue : Bool -> Model -> Model
setValue value model =
  { model | value = value }


{-| Returns attributes for a checkbox.
-}
attributes : Model -> List (Html.Attribute Msg)
attributes model =
  let
    actions =
      Ui.enabledActions
        model
        [ onClick Toggle
        , onKeys
            [ ( 13, Toggle )
            , ( 32, Toggle )
            ]
        ]
  in
    [ classList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        , ( "checked", model.value )
        ]
    ]
      ++ (Ui.tabIndex model)
      ++ actions
