module Ui.ColorPicker exposing
  (Model, Msg, init, onChange, subscriptions, update, view, render, setValue)

{-| An input component that displays a **Ui.ColorPanel** (in a dropdown) when
focused, allowing the user to manipulate the selected color.

# Model
@docs Model, Msg, init, subscriptions, update

# DSL
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html exposing (node, div, text, span)
import Html.Attributes exposing (style)
import Html.Lazy

import Ext.Color exposing (Hsv)
import Color exposing (Color)

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui.Helpers.Picker as Picker
import Ui.Native.Uid as Uid
import Ui.ColorPanel

import Ui.Styles.ColorPicker exposing (defaultStyle)
import Ui.Styles

{-| Representation of a color picker:
  - **disabled** - Whether or not the color picker is disabled
  - **readonly** - Whether or not the color picker is readonly
  - **uid** - The unique identifier of the color picker
  - **colorPanel** - The model of a color panel
  - **dropdown** - The model of the dropdown
-}
type alias Model =
  { colorPanel : Ui.ColorPanel.Model
  , dropdown : Dropdown
  , disabled : Bool
  , readonly : Bool
  , uid : String
  }


{-| Messages that a color picker can receive.
-}
type Msg
  = ColorPanel Ui.ColorPanel.Msg
  | Picker Picker.Msg


{-| Initializes a color picker with the given color.

    colorPicker = Ui.ColorPicker.init Color.yellow
-}
init : () -> Model
init _ =
  { colorPanel = Ui.ColorPanel.init ()
  , dropdown = Dropdown.init
  , disabled = False
  , readonly = False
  , uid = Uid.uid ()
  }
    |> Dropdown.offset 5


{-| Subscribe to the changes of a color picker.

    subscription = Ui.ColorPicker.onChange ColorPickerChanged colorPicker
-}
onChange : (Hsv -> msg) -> Model -> Sub msg
onChange msg model =
  Ui.ColorPanel.onChange msg model.colorPanel


{-| Subscriptions for a color picker.

    subscriptions =
      Sub.map ColorPicker (Ui.ColorPicker.subscriptions colorPicker)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.colorPanel)
    , Sub.map Picker (Picker.subscriptions model)
    ]


{-| Updates a color picker.

    ( updatedColorPicker, cmd ) = Ui.ColorPicker.update msg colorPicker
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Picker act ->
      ( Picker.update act model, Cmd.none )

    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Ui.ColorPanel.update act model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel effect )


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
  in
    Picker.view
      { address = Picker
      , attributes = Ui.Styles.apply defaultStyle
      , keyActions = []
      , contents =
          [ node "ui-color-picker-text" [] [ text color ]
          , node "ui-color-picker-rect" []
            [ node "ui-color-picker-background"
              [ style [ ( "background-color", color ) ] ]
              []
            ]
          ]
      , dropdownContents =
        [ Html.map ColorPanel (Ui.ColorPanel.view model.colorPanel)
        ]
      } model


{-| Sets the value of a color picker.

    ( updatedColorPicker, cmd ) =
      Ui.ColorPicker.setValue Color.black colorPicker
-}
setValue : Color -> Model -> ( Model, Cmd Msg )
setValue color model =
  let
    ( colorPanel, cmd ) =
      Ui.ColorPanel.setValue color model.colorPanel
  in
    ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel cmd )
