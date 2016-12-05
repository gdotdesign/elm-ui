module Ui.ColorFields exposing (..)

import Html.Events exposing (onBlur, onInput, on)
import Html.Attributes exposing (type_, defaultValue, id)
import Html exposing (node, div, input, text, span)

import Ext.Color exposing (Hsv, decodeHsv, encodeHsv)
import Color exposing (Color)
import Color.Convert

import Task
import DOM

import Json.Decode as Json

import Ui.Native.Uid as Uid

type alias Inputs =
  { hex : String
  , red : String
  , green : String
  , blue : String
  , alpha : String
  }


type alias Model =
  { value : Hsv
  , uid : String
  , disabled : Bool
  , readonly : Bool
  , inputs : Inputs
  }


init : () -> Model
init _ =
  { value = Ext.Color.toHsv Color.black
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , inputs =
    { hex = ""
    , red = ""
    , green = ""
    , blue = ""
    , alpha = ""
    }
  }
    |> updateInputs

type Msg
  = Hex String
  | Red String
  | Blue String
  | Green String
  | Alpha String
  | BlurHex
  | BlurRed
  | BlurBlue
  | BlurGreen
  | BlurAlpha
  | Done (Result DOM.Error (List ()))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ ({ inputs } as model) =
  case msg_ of
    Hex value ->
      ( { model | inputs = { inputs | hex = value } }, Cmd.none )

    Red value ->
      ( { model | inputs = { inputs | red = value } }, Cmd.none )

    Blue value ->
      ( { model | inputs = { inputs | blue = value } }, Cmd.none )

    Green value ->
      ( { model | inputs = { inputs | green = value } }, Cmd.none )

    Alpha value ->
      ( { model | inputs = { inputs | alpha = value } }, Cmd.none )

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

    Done _ ->
      ( model, Cmd.none )

setInputs : Model -> (Model, Cmd Msg)
setInputs model =
  let
    ({ inputs } as updatedModel) =
      updateInputs model

    cmd =
      [ DOM.setValue inputs.hex (DOM.idSelector (model.uid ++ "-hex"))
      , DOM.setValue inputs.red (DOM.idSelector (model.uid ++ "-red"))
      , DOM.setValue inputs.blue (DOM.idSelector (model.uid ++ "-blue"))
      , DOM.setValue inputs.green (DOM.idSelector (model.uid ++ "-green"))
      , DOM.setValue inputs.alpha (DOM.idSelector (model.uid ++ "-alpha"))
      ]
        |> Task.sequence
        |> Task.attempt Done
  in
    ( updatedModel, cmd )

updateInputs : Model -> Model
updateInputs ({ inputs } as model) =
  let
    {red, green, blue, alpha} =
      model.value
        |> Ext.Color.hsvToRgb
        |> Color.toRgb

    hex =
      Color.Convert.colorToHex (Ext.Color.hsvToRgb model.value)

    updatedInputs =
      { inputs
      | hex = hex
      , red = toString red
      , green = toString green
      , alpha = toString (round (alpha * 100))
      , blue = toString blue
      }
  in
    { model | inputs = updatedInputs }

view : Model -> Html.Html Msg
view ({ inputs } as model) =
  node "ui-color-fields" []
    [ div []
      [ input
        [ defaultValue inputs.hex
        , onInput Hex
        , onBlur BlurHex
        , id (model.uid ++ "-hex")
        ] []
      , span [] [ text "Hex" ]
      ]
    , div []
      [ input
        [ type_ "number"
        , Html.Attributes.min "0"
        , Html.Attributes.max "255"
        , onInput Red
        , on "change" (Json.succeed BlurRed)
        , defaultValue inputs.red
        , id (model.uid ++ "-red")
        ] []
      , span [] [ text "R" ]
      ]
    , div []
      [ input
        [ type_ "number"
        , onInput Green
        , on "change" (Json.succeed BlurGreen)
        , Html.Attributes.min "0"
        , Html.Attributes.max "255"
        , defaultValue inputs.green
        , id (model.uid ++ "-green")
        ] []
      , span [] [ text "G" ]
      ]
    , div []
      [ input
        [ type_ "number"
        , onInput Blue
        , on "change" (Json.succeed BlurBlue)
        , Html.Attributes.min "0"
        , Html.Attributes.max "255"
        , defaultValue inputs.blue
        , id (model.uid ++ "-blue")
        ] []
      , span [] [ text "B" ]
      ]
    , div []
      [ input
        [ type_ "number"
        , onInput Alpha
        , on "change" (Json.succeed BlurAlpha)
        , Html.Attributes.min "0"
        , Html.Attributes.max "100"
        , defaultValue inputs.alpha
        , id (model.uid ++ "-alpha")
        ] []
      , span [] [ text "A" ]
      ]
    ]
