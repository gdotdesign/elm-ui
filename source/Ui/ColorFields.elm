module Ui.ColorFields exposing
  (Model, Msg, init, update, onChange, view, render, setValue)

{-| A component for manipulating a color's red, green, blue and alpha values
along with the ability to set it with a hex (FFFFFF) value.

# Model
@docs Model, Msg, init, update

# Events
@docs onChange

# Functions
@docs setValue

# View
@docs render, view
-}

import Html.Attributes exposing ( type_, defaultValue, id, spellcheck )
import Html.Events exposing (onBlur, onInput, on)
import Html exposing (node, input, text)
import Html.Lazy

import Ext.Color exposing (Hsv, decodeHsv, encodeHsv)
import Color exposing (Color)
import Color.Convert

import Task
import DOM

import Json.Decode as Json

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui

import Ui.Styles.ColorFields exposing (defaultStyle)
import Ui.Styles

{-| Represents the values of the inputs.
-}
type alias Inputs =
  { green : String
  , alpha : String
  , blue : String
  , hex : String
  , red : String
  }


{-| Representation of a color fields component:
  - **disabled** - Whether or not the color fields is disabled
  - **readonly** - Whether or not the color fields is readonly
  - **uid** - The unique identifier of the color fields
  - **value** - The current value of the a color fields
  - **inputs** - The inputs to hold spearate values
-}
type alias Model =
  { disabled : Bool
  , readonly : Bool
  , inputs : Inputs
  , uid : String
  , value : Hsv
  }


{-| Messages that a color fields component can receive.
-}
type Msg
  = Done (Result DOM.Error (List ()))
  | Alpha String
  | Green String
  | Blue String
  | Hex String
  | Red String
  | BlurGreen
  | BlurAlpha
  | BlurBlue
  | BlurHex
  | BlurRed


{-| Initializes a color fields component.

    colorFields = Ui.ColorFields.init ()
-}
init : () -> Model
init _ =
  { value = Ext.Color.toHsv Color.black
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , inputs =
      { green = ""
      , alpha = ""
      , blue = ""
      , red = ""
      , hex = ""
      }
  }
    |> updateInputs


{-| Subscribe for the changes of a color fields.

    subscriptions =
      Ui.ColorFields.onChange ColorFieldsChanged colorFields
-}
onChange : (Hsv -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listen
    model.uid
    (Emitter.decode decodeHsv (Ext.Color.toHsv Color.black) msg)


{-| Updates a color fields component.

    ( updatedColorFields, cmd ) = Ui.ColorFields.update msg colorFields
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ ({ inputs } as model) =
  case msg_ of
    Green value ->
      ( { model | inputs = { inputs | green = value } }, Cmd.none )

    Alpha value ->
      ( { model | inputs = { inputs | alpha = value } }, Cmd.none )

    Blue value ->
      ( { model | inputs = { inputs | blue = value } }, Cmd.none )

    Red value ->
      ( { model | inputs = { inputs | red = value } }, Cmd.none )

    Hex value ->
      ( { model | inputs = { inputs | hex = value } }, Cmd.none )

    BlurHex ->
      let
        updatedModel =
          case Color.Convert.hexToColor inputs.hex of
            Just color ->
              let
                alpha =
                  Ext.Color.hsvToRgb model.value
                    |> Color.toRgb
                    |> .alpha

                value =
                  Ext.Color.toHsv color
                    |> Ext.Color.setAlpha alpha
              in
                { model | value = value }

            Nothing ->
              model
      in
        setInputs updatedModel
          |> sendValue

    BlurRed ->
      let
        updatedModel =
          case String.toInt inputs.red of
            Ok red ->
              { model | value = Ext.Color.setRed red model.value }

            Err _ ->
              model
      in
        setInputs updatedModel
          |> sendValue

    BlurBlue ->
      let
        updatedModel =
          case String.toInt inputs.blue of
            Ok blue ->
              { model | value = Ext.Color.setBlue blue model.value }

            Err _ ->
              model
      in
        setInputs updatedModel
          |> sendValue

    BlurGreen ->
      let
        updatedModel =
          case String.toInt inputs.green of
            Ok green ->
              { model | value = Ext.Color.setGreen green model.value }

            Err _ ->
              model
      in
        setInputs updatedModel
          |> sendValue

    BlurAlpha ->
      let
        updatedModel =
          case String.toFloat inputs.alpha of
            Ok alpha ->
              { model | value = Ext.Color.setAlpha (alpha / 100) model.value }

            Err _ ->
              model
      in
        setInputs updatedModel
          |> sendValue

    Done _ ->
      ( model, Cmd.none )


{-| Sends the value to the cannel.
-}
sendValue : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
sendValue (model, cmd) =
  ( model, Cmd.batch [ Emitter.send model.uid (encodeHsv model.value), cmd ] )


{-| Sets the value of a color fields component.

    ( updatedColorFields, cmd ) =
      Ui.ColorFields.setValue Color.black colorfields
-}
setValue : Hsv -> Model -> ( Model, Cmd Msg )
setValue value model =
  { model | value = value }
    |> setInputs


{-| Sets the inputs to match the current value of a color fields component.
-}
setInputs : Model -> ( Model, Cmd Msg )
setInputs model =
  let
    ({ inputs } as updatedModel) =
      updateInputs model

    setCommand =
      [ DOM.setValue inputs.green (DOM.idSelector (model.uid ++ "-green"))
      , DOM.setValue inputs.alpha (DOM.idSelector (model.uid ++ "-alpha"))
      , DOM.setValue inputs.blue (DOM.idSelector (model.uid ++ "-blue"))
      , DOM.setValue inputs.red (DOM.idSelector (model.uid ++ "-red"))
      , DOM.setValue inputs.hex (DOM.idSelector (model.uid ++ "-hex"))
      ]
        |> Task.sequence
        |> Task.attempt Done
  in
    ( updatedModel, setCommand  )


{-| Updates the inputs to match the current value of a color fields component.
-}
updateInputs : Model -> Model
updateInputs ({ inputs } as model) =
  let
    { red, green, blue, alpha } =
      model.value
        |> Ext.Color.hsvToRgb
        |> Color.toRgb

    hex =
      model.value
        |> Ext.Color.hsvToRgb
        |> Color.Convert.colorToHex
        |> String.toUpper

    updatedInputs =
      { inputs
        | alpha = toString (round (alpha * 100))
        , green = toString green
        , blue = toString blue
        , red = toString red
        , hex = hex
      }
  in
    { model | inputs = updatedInputs }


{-| Renders a number input.
-}
renderInput :
  String
  -> String
  -> String
  -> (String -> Msg)
  -> Msg
  -> String
  -> Model
  -> Html.Html Msg
renderInput name min max msg blurMsg value model =
  let
    baseAttributes =
      [ id (model.uid ++ "-" ++ name)
      , defaultValue value
      , spellcheck False
      , type_ "number"
      ]

    attributes =
      [ Ui.attributeList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
      , [ on "change" (Json.succeed blurMsg)
        , Html.Attributes.min min
        , Html.Attributes.max max
        , onInput msg
        ]
      ]
      |> List.concat
  in
    node "ui-color-fields-column" []
      [ input (baseAttributes ++ attributes) []
      , node "ui-color-fields-label" []
        [ text (String.toUpper (String.left 1 name)) ]
      ]


{-| Laizly renders a color fields component.
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a color fields component.
-}
render : Model -> Html.Html Msg
render ({ inputs } as model) =
  let
    baseHexAttributes =
      [ defaultValue inputs.hex
      , id (model.uid ++ "-hex")
      , spellcheck False
      ]

    hexAttributes =
      [ Ui.attributeList
        [ ( "disabled", model.disabled )
        , ( "readonly", model.readonly )
        ]
      , [ on "change" (Json.succeed BlurHex)
        , onBlur BlurHex
        , onInput Hex
        ]
      ]
      |> List.concat
  in
    node "ui-color-fields"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ node "ui-color-fields-column" []
          [ input (baseHexAttributes ++ hexAttributes) []
          , node "ui-color-fields-label" [] [ text "Hex" ]
          ]
      , renderInput "red"   "0" "255" Red   BlurRed   inputs.red   model
      , renderInput "green" "0" "255" Green BlurGreen inputs.green model
      , renderInput "blue"  "0" "255" Blue  BlurBlue  inputs.blue  model
      , renderInput "alpha" "0" "100" Alpha BlurAlpha inputs.alpha model
    ]
