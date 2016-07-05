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

import Html.Attributes exposing (classList, style)
import Html.Events exposing (onBlur, onClick)
import Html exposing (node, div, text)
import Html.Lazy
import Html.App

import Ext.Color exposing (Hsv)
import Color exposing (Color)

import Ui.Helpers.Dropdown as Dropdown
import Ui.ColorPanel
import Ui


{-| Representation of a color picker:
  - **colorPanel** - The model of a color panel
  - **dropdownPosition** - Where the dropdown is positioned (bottom / top)
  - **disabled** - Whether or not the color picker is disabled
  - **readonly** - Whether or not the color picker is readonly
  - **open** - Whether or not the color picker is open
-}
type alias Model =
  { colorPanel : Ui.ColorPanel.Model
  , dropdownPosition : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }


{-| Messages that a color picker can receive.
-}
type Msg
  = ColorPanel Ui.ColorPanel.Msg
  | Toggle Dropdown.Dimensions
  | Focus Dropdown.Dimensions
  | Close Dropdown.Dimensions
  | Blur
  | NoOp


{-| Initializes a color picker with the given color.

    colorPicker = Ui.ColorPicker.init Color.yellow
-}
init : Color.Color -> Model
init color =
  { colorPanel = Ui.ColorPanel.init color
  , dropdownPosition = "bottom"
  , disabled = False
  , readonly = False
  , open = False
  }


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
  Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.colorPanel)


{-| Updates a color picker.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Ui.ColorPanel.update act model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel effect )

    Focus dimensions ->
      ( Dropdown.openWithDimensions dimensions model, Cmd.none )

    Close _ ->
      ( Dropdown.close model, Cmd.none )

    Blur ->
      ( Dropdown.close model, Cmd.none )

    Toggle dimensions ->
      ( Dropdown.toggleWithDimensions dimensions model, Cmd.none )

    NoOp ->
      ( model, Cmd.none )


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
        [ Dropdown.onWithDimensions "focus" Focus
        , onBlur Blur
        , Dropdown.onKeysWithDimensions
            [ ( 27, Close )
            , ( 13, Toggle )
            ]
        ]

    open =
      model.open && not model.disabled && not model.readonly
  in
    node
      "ui-color-picker"
      ([ classList
          [ ( "dropdown-open", open )
          , ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
       ]
        ++ actions
        ++ (Ui.tabIndex model)
      )
      [ div [] [ text color ]
      , node
          "ui-color-picker-rect"
          []
          [ div [ style [ ( "background-color", color ) ] ] [] ]
      , Dropdown.view
          NoOp
          model.dropdownPosition
          [ node "ui-dropdown-overlay" [ onClick Blur ] []
          , Html.App.map ColorPanel (Ui.ColorPanel.view model.colorPanel)
          ]
      ]


{-| Sets the vale of a color picker.

    Ui.ColorPicker.setValue Color.black colorPicker
-}
setValue : Color -> Model -> Model
setValue color model =
  { model | colorPanel = Ui.ColorPanel.setValue color model.colorPanel }
