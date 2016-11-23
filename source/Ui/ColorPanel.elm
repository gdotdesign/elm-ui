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

import Html.Attributes exposing (style, classList, type_, id, value)
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

import DOM exposing (Position)

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
  { alphaDrag : DragModel
  , hueDrag : DragModel
  , drag : DragModel
  , tempHex : String
  , disabled : Bool
  , readonly : Bool
  , uid : String
  , value : Hsv
  }


type alias DragModel =
  { drag : Drag.Drag
  , uid : String
  }

{-| Messages that a color panel can receive.
-}
type Msg
  = MoveAlpha Position
  | MoveRect Position
  | MoveHue Position
  | LiftAlpha Position
  | LiftRect Position
  | LiftHue Position
  | SetAlpha String
  | SetGreen String
  | SetBlue String
  | SetHex String
  | SetRed String
  | FromHex
  | End


{-| Initializes a color panel with the given Elm color.

    colorPanel = Ui.ColorPanel.init Color.blue
-}
init : Color -> Model
init color =
  let
    uid = Uid.uid ()
  in
    { value = Ext.Color.toHsv color
    , uid = uid
    , alphaDrag = initDrag (uid ++ "alpha")
    , hueDrag = initDrag (uid ++ "hue")
    , drag = initDrag (uid ++ "rect")
    , disabled = False
    , readonly = False
    , tempHex = Color.Convert.colorToHex color
    }


initDrag : String -> DragModel
initDrag id =
  { uid = id
  , drag = Drag.init
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
  Sub.batch
    [ Drag.onMove MoveHue model.hueDrag
    , Drag.onMove MoveAlpha model.alphaDrag
    , Drag.onMove MoveRect model.drag
    , Drag.onEnd End model.drag
    , Drag.onEnd End model.hueDrag
    , Drag.onEnd End model.alphaDrag
    ]


{-| Updates a color panel.

    Ui.ColorPanel.update msg colorPanel
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    LiftRect position ->
      { model | drag = Drag.lift position model.drag }
        |> handleRect position

    LiftAlpha position ->
      { model | alphaDrag = Drag.lift position model.alphaDrag }
        |> handleAlpha position

    LiftHue position ->
      { model | hueDrag = Drag.lift position model.hueDrag }
        |> handleHue position

    MoveHue position ->
      handleHue position model

    MoveAlpha position ->
      handleAlpha position model

    MoveRect position ->
      handleRect position model

    End ->
      ( handleClick model, Cmd.none )

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
        [ Drag.liftHandler act ]
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
                ([ id model.drag.uid
                 , style
                    [ ( "background-color", background )
                    , ( "cursor"
                      , if model.drag.drag.dragging then
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
                (id model.hueDrag.uid :: action LiftHue)
                [ renderHandle (asPercent color.hue) "" ]
            ]
        , node
            "ui-color-panel-alpha"
            (id model.alphaDrag.uid :: action LiftAlpha)
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
            [ type_ "number"
            , Html.Attributes.min "0", Html.Attributes.max "255"
            , onInput SetRed
            , value (toString red)
            ] []
          , span [] [ text "R" ]
          ]
        , div []
          [ input
            [ type_ "number"
            , onInput SetGreen
            , Html.Attributes.min "0"
            , Html.Attributes.max "255"
            , value (toString green)
            ] []
          , span [] [ text "G" ]
          ]
        , div []
          [ input
            [ type_ "number"
            , onInput SetBlue
            , Html.Attributes.min "0"
            , Html.Attributes.max "255"
            , value (toString blue)
            ] []
          , span [] [ text "B" ]
          ]
        , div []
          [ input
            [ type_ "number"
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
updateValue : Hsv -> Model -> ( Model, Cmd Msg )
updateValue value model =
  if model.value == value then
    ( model, Cmd.none )
  else
    ( { model
        | value = value
        , tempHex = Color.Convert.colorToHex (Ext.Color.hsvToRgb value)
      }
    , Emitter.send model.uid (encodeHsv value)
    )


{-| Updates a color panel, stopping the drags if the mouse isn't pressed.
-}
handleClick : Model -> Model
handleClick model =
  let
    alphaDrag =
      Drag.end model.alphaDrag

    hueDrag =
      Drag.end model.hueDrag

    drag =
      Drag.end model.drag
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
handleHue : Position -> Model -> (Model, Cmd Msg)
handleHue position ({ value } as model) =
  let
    hue =
      Drag.relativePercentPosition position model.hueDrag
        |> .top
        |> clamp 0 1

    updatedValue =
      if value.hue == hue then
        value
      else
        { value | hue = hue}
  in
    updateValue updatedValue model


{-| Handles the value / saturation drag.
-}
handleRect : Position -> Model -> (Model, Cmd Msg)
handleRect position ({ value } as model) =
  let
    { top, left } =
      Drag.relativePercentPosition position model.drag

    saturation =
      clamp 0 1 left

    colorValue =
      1 - (clamp 0 1 top)

    updatedValue =
      if value.saturation == saturation
      && value.value == colorValue
      then
        value
      else
        { value | saturation = saturation, value = colorValue }
  in
    updateValue updatedValue model

{-| Handles the alpha drag.
-}
handleAlpha : Position -> Model -> (Model, Cmd Msg)
handleAlpha position ({ value } as model) =
  let
    alpha =
      Drag.relativePercentPosition position model.alphaDrag
        |> .left
        |> clamp 0 1

    updatedValue =
      if value.alpha == alpha then
        value
      else
        { value | alpha = alpha }
  in
    updateValue updatedValue model


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
