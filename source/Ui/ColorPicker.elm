module Ui.ColorPicker exposing
  (Model, Msg, init, subscribe, subscriptions, update, view, render, setValue)

{-| An input component that displays a **Ui.ColorPanel** (in a dropdown) when
focused, allowing the user to manipulate the selected color.

# Model
@docs Model, Msg, init, subscribe, subscriptions, update

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Events exposing (onBlur, onMouseDown, onFocus, on)
import Html.Attributes exposing (classList, style)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node, div, text)
import Html.Lazy

import Ext.Color exposing (Hsv)
import Color exposing (Color)

import Json.Decode as Json

import Ui.Helpers.Dropdown_ as Dropdown
import Ui.Native.Uid as Uid
import Ui.ColorPanel
import Ui


{-| Representation of a color picker:
  - **colorPanel** - The model of a color panel
  - **disabled** - Whether or not the color picker is disabled
  - **readonly** - Whether or not the color picker is readonly
  - **open** - Whether or not the color picker is open
-}
type alias Model =
  { colorPanel : Ui.ColorPanel.Model
  , dropdown : Dropdown.Dropdown
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }


{-| Messages that a color picker can receive.
-}
type Msg
  = ColorPanel Ui.ColorPanel.Msg
  | Dropdown Dropdown.Msg
  | Toggle
  | Focus
  | Close
  | Blur


{-| Initializes a color picker with the given color.

    colorPicker = Ui.ColorPicker.init Color.yellow
-}
init : Color.Color -> Model
init color =
  { colorPanel = Ui.ColorPanel.init color
  , dropdown = Dropdown.init
  , disabled = False
  , readonly = False
  , uid = Uid.uid ()
  }
    |> Dropdown.offset 5


{-| Subscribe to the changes of a color picker.

    ...
    subscriptions =
      \model ->
        Ui.ColorPicker.subscribe
          ColorPickerChanged
          model.colorPicker
    ...
-}
subscribe : (Hsv -> msg) -> Model -> Sub msg
subscribe msg model =
  Ui.ColorPanel.subscribe msg model.colorPanel


{-| Subscriptions for a color picker.

    ...
    subscriptions =
      \model ->
        Sub.map
          ColorPicker
          (Ui.ColorPicker.subscriptions model.colorPicker)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.colorPanel)
    , Sub.map Dropdown (Dropdown.subscriptions model)
    ]


{-| Updates a color picker.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Dropdown msg ->
      (Dropdown.update msg model, Cmd.none)

    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Ui.ColorPanel.update act model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel effect )

    Toggle ->
      ( Dropdown.toggle model, Cmd.none)

    Focus ->
      ( Dropdown.open model, Cmd.none )

    Close ->
      ( Dropdown.close model, Cmd.none )

    Blur ->
      let
        selector =
          "[id='" ++ model.uid ++ "'] *:focus"
      in
        if Native.Dom.test selector then
          ( model, Cmd.none )
        else
          ( Dropdown.close model, Cmd.none )

{-| Lazily renders a color picker.

    Ui.ColorPicker.view colorPicker
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a color picker.

    Ui.ColorPicker.render colorPicker
-}
render : Model -> Html.Html Msg
render model =
  let
    color =
      Ext.Color.toCSSRgba model.colorPanel.value

    actions =
      Ui.enabledActions
        model
        [ onFocus Focus
        , onBlur Blur
        , on "focusout" (Json.succeed Blur)
        , onKeys
            [ ( 27, Close )
            , ( 13, Toggle )
            ]
        ]

    toggleAction =
      if Native.Dom.test ("[id='" ++ model.uid ++ "']:focus") then
        [ onMouseDown Toggle ]
      else
        []

    finalActions =
      [ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      ]
        ++ actions
        ++ (Ui.tabIndex model)
  in
    Dropdown.view
      { tag = "ui-color-picker"
      , address = Dropdown
      , attributes = finalActions
      , children =
          [ node "ui-color-picker-input"
            toggleAction
            [ text color
            , node
                "ui-color-picker-rect"
                []
                [ div [ style [ ( "background-color", color ) ] ] [] ]
            ]
          ]
      , contents = [ Html.map ColorPanel (Ui.ColorPanel.view model.colorPanel)]
      } model
    {-
    node
      "ui-color-picker"
      (
      )
      [
      , Dropdown.view
          model.dropdownPosition
          [ node "ui-dropdown-overlay" [ onClick Blur ] []
          , Html.map ColorPanel (Ui.ColorPanel.view model.colorPanel)
          ]
      ]
    -}


{-| Sets the value of a color picker.

    Ui.ColorPicker.setValue Color.black colorPicker
-}
setValue : Color -> Model -> Model
setValue color model =
  { model | colorPanel = Ui.ColorPanel.setValue color model.colorPanel }
