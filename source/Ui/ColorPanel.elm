module Ui.ColorPanel exposing
  (Model, Msg, init, subscribe, subscriptions, update, view, render, setValue)

{-| Color panel component for selecting a colors **hue**, **saturation**,
**value** and **alpha** components with draggable interfaces.

# Model
@docs Model, Msg, init, update, subscribe, subscriptions

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Attributes exposing (style, classList, type', id, value)
import Html.Events.Geometry exposing (Dimensions, onWithDimensions)
import Html exposing (node, div, text, input, span)
import Html.Events exposing (onInput, onBlur)
import Html.Lazy

import Ext.Color exposing (Hsv, decodeHsv, encodeHsv)
import Color exposing (Color)
import Color.Convert
import String
import Task

import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui

import Native.Dom

{-| Representation of a color panel:
  - **alphaDrag** - The drag model of the alpha slider
  - **hueDrag** - The drag model of the hue slider
  - **drag** - The drag model of the value / saturation rectangle
  - **disabled** - Whether or not the color panel is disabled
  - **readonly** - Whether or not the color panel is editable
  - **uid** - The unique identifier of the color panel
  - **value** - The current HSV color
-}
type alias Model =
  { alphaDrag : Drag.Model
  , hueDrag : Drag.Model
  , drag : Drag.Model
  , tempHex : String
  , disabled : Bool
  , readonly : Bool
  , uid : String
  , value : Hsv
  }


{-| Messages that a color panel can receive.
-}
type Msg
  = Move ( Float, Float )
  | LiftAlpha Dimensions
  | LiftRect Dimensions
  | LiftHue Dimensions
  | SetAlpha String
  | SetGreen String
  | SetBlue String
  | SetHex String
  | SetRed String
  | Click Bool
  | FromHex


{-| Initializes a color panel with the given Elm color.

    colorPanel = Ui.ColorPanel.init Color.blue
-}
init : Color -> Model
init color =
  { value = Ext.Color.toHsv color
  , uid = Uid.uid ()
  , alphaDrag = Drag.init
  , hueDrag = Drag.init
  , drag = Drag.init
  , disabled = False
  , readonly = False
  , tempHex = Color.Convert.colorToHex color
  }


{-| Subscribe for the changes of a color panel.

    ...
    subscriptions =
      \model ->
        Ui.ColorPanel.subscribe
          ColorPanelChanged
          model.colorPanel
    ...
-}
subscribe : (Hsv -> msg) -> Model -> Sub msg
subscribe msg model =
  Emitter.listen
    model.uid
    (Emitter.decode decodeHsv (Ext.Color.toHsv Color.black) msg)


{-| Subscriptions for a color panel.

    ...
    subscriptions =
      \model ->
        Sub.map
          ColorPanel
          (Ui.ColorPanel.subscriptions model.colorPanel)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  let
    dragging =
      model.alphaDrag.dragging
        || model.hueDrag.dragging
        || model.drag.dragging
  in
    Drag.subscriptions Move Click dragging


{-| Updates a color panel.

    Ui.ColorPanel.update msg colorPanel
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    LiftRect ( position, dimensions, size ) ->
      { model | drag = Drag.lift dimensions position model.drag }
        |> handleMove position.left position.top

    LiftAlpha ( position, dimensions, size ) ->
      { model | alphaDrag = Drag.lift dimensions position model.alphaDrag }
        |> handleMove position.left position.top

    LiftHue ( position, dimensions, size ) ->
      { model | hueDrag = Drag.lift dimensions position model.hueDrag }
        |> handleMove position.left position.top

    Move ( x, y ) ->
      handleMove x y model

    Click pressed ->
      ( handleClick pressed model, Cmd.none )

    SetRed value ->
      let
        red =
          value
            |> String.toInt
            |> Result.withDefault 0

        color =
          model.value
            |> Ext.Color.updateColor (\c -> { c | red = clamp 0 255 red })
      in
        (setValue color model, Cmd.none)

    SetGreen value ->
      let
        green =
          value
            |> String.toInt
            |> Result.withDefault 0

        color =
          model.value
            |> Ext.Color.updateColor (\c -> { c | green = clamp 0 255 green })
      in
        (setValue color model, Cmd.none)

    SetBlue value ->
      let
        blue =
          value
            |> String.toInt
            |> Result.withDefault 0

        color =
          model.value
            |> Ext.Color.updateColor (\c -> { c | blue = clamp 0 255 blue })
      in
        (setValue color model, Cmd.none)

    SetHex value ->
      ({ model | tempHex = value }, Cmd.none)

    FromHex ->
      case Color.Convert.hexToColor model.tempHex of
        Just color ->
          ({ model | value = Ext.Color.toHsv color }, Cmd.none)
        _ ->
          ({ model | tempHex = Color.Convert.colorToHex (Ext.Color.hsvToRgb model.value) }, Cmd.none)

    SetAlpha value ->
      let
        alpha =
          value
            |> String.toInt
            |> Result.withDefault 0
            |> toFloat

        color =
          model.value
            |> Ext.Color.updateColor (\c -> { c | alpha = clamp 0 1 (alpha / 100) })
      in
        (setValue color model, Cmd.none)


{-| Lazily renders a color panel.

    Ui.ColorPanel.view colorPanel
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a color panel.

    Ui.ColorPanel.render colorPanel
-}
render : Model -> Html.Html Msg
render model =
  let
    background =
      "hsla(" ++ (toString (round (model.value.hue * 360))) ++ ", 100%, 50%, 1)"

    color =
      model.value

    {red, green, blue, alpha} =
      model.value
        |> Ext.Color.hsvToRgb
        |> Color.toRgb

    colorTransparent =
      (Ext.Color.toCSSRgba { color | alpha = 0 })

    colorFull =
      (Ext.Color.toCSSRgba { color | alpha = 1 })

    gradient =
      "linear-gradient(90deg, " ++ colorTransparent ++ "," ++ colorFull ++ ")"

    asPercent value =
      (toString (value * 100)) ++ "%"

    action act =
      Ui.enabledActions
        model
        [ onWithDimensions "mousedown" False act ]
  in
    node
      "ui-color-panel"
      [ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      ]
      [ node "ui-color-panel-hsv" []
        [ div []
            [ node
                "ui-color-panel-rect"
                ([ style
                    [ ( "background-color", background )
                    , ( "cursor"
                      , if model.drag.dragging then
                          "move"
                        else
                          ""
                      )
                    ]
                 ]
                  ++ (action LiftRect)
                )
                [ renderHandle
                    (asPercent (1 - color.value))
                    (asPercent color.saturation)
                ]
            , node
                "ui-color-panel-hue"
                (action LiftHue)
                [ renderHandle (asPercent color.hue) "" ]
            ]
        , node
            "ui-color-panel-alpha"
            (action LiftAlpha)
            [ div [ style [ ( "background-image", gradient ) ] ] []
            , renderHandle "" (asPercent color.alpha)
            ]
        ]
      , node "ui-color-panel-controls" []
        [ div []
          [ input
            [ value model.tempHex
            , onInput SetHex
            , onBlur FromHex
            ] []
          , span [] [ text "Hex" ]
          ]
        , div []
          [ input
            [ type' "number"
            , Html.Attributes.min "0", Html.Attributes.max "255"
            , onInput SetRed
            , value (toString red)
            ] []
          , span [] [ text "R" ]
          ]
        , div []
          [ input
            [ type' "number"
            , onInput SetGreen
            , Html.Attributes.min "0"
            , Html.Attributes.max "255"
            , value (toString green)
            ] []
          , span [] [ text "G" ]
          ]
        , div []
          [ input
            [ type' "number"
            , onInput SetBlue
            , Html.Attributes.min "0"
            , Html.Attributes.max "255"
            , value (toString blue)
            ] []
          , span [] [ text "B" ]
          ]
        , div []
          [ input
            [ type' "number"
            , onInput SetAlpha
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , value (toString (round (alpha * 100)))
            ] []
          , span [] [ text "A" ]
          ]
        ]
      ]

{-| Sets the value of a color panel.

    Ui.ColorPanel.setValue Color.black colorPanel
-}
setValue : Color -> Model -> Model
setValue color model =
  { model | value = Ext.Color.toHsv color }



--------------------------------- PRIVATE --------------------------------------


{-| Updates a color panel color by coordinates.
-}
handleMove : Float -> Float -> Model -> ( Model, Cmd Msg )
handleMove x y model =
  let
    color =
      if model.drag.dragging then
        handleRect x y model.value model.drag
      else if model.hueDrag.dragging then
        handleHue x y model.value model.hueDrag
      else if model.alphaDrag.dragging then
        handleAlpha x y model.value model.alphaDrag
      else
        model.value
  in
    if model.value == color then
      ( model, Cmd.none )
    else
      ( { model
          | value = color
          , tempHex = Color.Convert.colorToHex (Ext.Color.hsvToRgb model.value)
        }
      , Emitter.send model.uid (encodeHsv color)
      )


{-| Updates a color panel, stopping the drags if the mouse isn't pressed.
-}
handleClick : Bool -> Model -> Model
handleClick value model =
  let
    alphaDrag =
      Drag.handleClick value model.alphaDrag

    hueDrag =
      Drag.handleClick value model.hueDrag

    drag =
      Drag.handleClick value model.drag
  in
    if
      model.alphaDrag
        == alphaDrag
        && model.hueDrag
        == hueDrag
        && model.drag
        == drag
    then
      model
    else
      { model
        | alphaDrag = alphaDrag
        , hueDrag = hueDrag
        , drag = drag
      }


{-| Handles the hue drag.
-}
handleHue : Float -> Float -> Hsv -> Drag.Model -> Hsv
handleHue x y color drag =
  let
    { top } =
      Drag.relativePercentPosition x y drag

    hue =
      clamp 0 1 top
  in
    if color.hue == hue then
      color
    else
      { color | hue = hue }


{-| Handles the value / saturation drag.
-}
handleRect : Float -> Float -> Hsv -> Drag.Model -> Hsv
handleRect x y color drag =
  let
    { top, left } =
      Drag.relativePercentPosition x y drag

    saturation =
      clamp 0 1 left

    value =
      1 - (clamp 0 1 top)
  in
    if
      color.saturation
        == saturation
        && color.value
        == value
    then
      color
    else
      { color | saturation = saturation, value = value }


{-| Handles the alpha drag.
-}
handleAlpha : Float -> Float -> Hsv -> Drag.Model -> Hsv
handleAlpha x y color drag =
  let
    { left } =
      Drag.relativePercentPosition x y drag

    alpha =
      clamp 0 1 left
  in
    if color.alpha == alpha then
      color
    else
      { color | alpha = alpha }


{-| Renders a handle
-}
renderHandle : String -> String -> Html.Html Msg
renderHandle top left =
  node
    "ui-color-panel-handle"
    [ style
        [ ( "top", top )
        , ( "left", left )
        ]
    ]
    []
