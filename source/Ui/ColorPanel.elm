module Ui.ColorPanel exposing
  (Model, Msg, init, onChange, subscriptions, update, view, render, setValue)

{-| A component for manipulating a color's **hue**, **saturation**,
**value** and **alpha** components with draggable interfaces.

# Model
@docs Model, Msg, init, update, subscriptions

# Events
@docs onChange

# View
@docs view, render

# Functions
@docs setValue
-}

import Html.Attributes exposing (style, id)
import Html exposing (node)
import Html.Lazy

import Ext.Color exposing (Hsv, decodeHsv, encodeHsv)
import Color exposing (Color)

import Ui.ColorFields as ColorFields
import Ui.Helpers.Emitter as Emitter
import Ui.Helpers.Drag as Drag
import Ui.Native.Uid as Uid
import Ui

import Ui.Styles.ColorPanel exposing (defaultStyle)
import Ui.Styles

import Ext.Number

import DOM exposing (Position)

{-| Representation of a color panel:
  - **drag** - The drag model of the value / saturation rectangle
  - **disabled** - Whether or not the color panel is disabled
  - **readonly** - Whether or not the color panel is editable
  - **uid** - The unique identifier of the color panel
  - **alphaDrag** - The drag model of the alpha slider
  - **hueDrag** - The drag model of the hue slider
  - **fields** - The model for the color fields
  - **value** - The current HSV color
-}
type alias Model =
  { fields : ColorFields.Model
  , alphaDrag : DragModel
  , hueDrag : DragModel
  , drag : DragModel
  , disabled : Bool
  , readonly : Bool
  , uid : String
  , value : Hsv
  }


{-| Model for drags.
-}
type alias DragModel =
  { drag : Drag.Drag
  , uid : String
  }


{-| Messages that a color panel can receive.
-}
type Msg
  = Fields ColorFields.Msg
  | LiftAlpha Position
  | MoveAlpha Position
  | LiftRect Position
  | MoveRect Position
  | MoveHue Position
  | LiftHue Position
  | SetValue Hsv
  | End


{-| Initializes a color panel with the given Elm color.

    colorPanel = Ui.ColorPanel.init ()
-}
init : () -> Model
init _ =
  let
    uid = Uid.uid ()
  in
    { alphaDrag = initDrag (uid ++ "alpha")
    , value = Ext.Color.toHsv Color.black
    , hueDrag = initDrag (uid ++ "hue")
    , drag = initDrag (uid ++ "rect")
    , fields = ColorFields.init ()
    , disabled = False
    , readonly = False
    , uid = uid
    }


{-| Initializes a drag model.
-}
initDrag : String -> DragModel
initDrag id =
  { drag = Drag.init
  , uid = id
  }


{-| Subscribe for the changes of a color panel.

    subscription = Ui.ColorPanel.onChange ColorPanelChanged colorPanel
-}
onChange : (Hsv -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listen
    model.uid
    (Emitter.decode decodeHsv (Ext.Color.toHsv Color.black) msg)


{-| Subscriptions for a color panel.

    subscriptions =
      Sub.map ColorPanel (Ui.ColorPanel.subscriptions colorPanel)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ ColorFields.onChange SetValue model.fields
    , Drag.onMove MoveAlpha model.alphaDrag
    , Drag.onMove MoveHue model.hueDrag
    , Drag.onMove MoveRect model.drag
    , Drag.onEnd End model.alphaDrag
    , Drag.onEnd End model.hueDrag
    , Drag.onEnd End model.drag
    ]


{-| Updates a color panel.

    ( updatedColorPanel, cmd ) = Ui.ColorPanel.update msg colorPanel
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    LiftAlpha position ->
      { model | alphaDrag = Drag.lift position model.alphaDrag }
        |> handleAlpha position

    LiftHue position ->
      { model | hueDrag = Drag.lift position model.hueDrag }
        |> handleHue position

    LiftRect position ->
      { model | drag = Drag.lift position model.drag }
        |> handleRect position

    MoveAlpha position ->
      handleAlpha position model

    MoveRect position ->
      handleRect position model

    MoveHue position ->
      handleHue position model

    End ->
      ( handleClick model, Cmd.none )

    SetValue color ->
      ({ model | value = color }, Emitter.send model.uid (encodeHsv color))

    Fields msg ->
      let
        (fields, cmd) =
          ColorFields.update msg model.fields
      in
        ( { model | fields = fields }, Cmd.map Fields cmd)


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
render ({ fields } as model) =
  let
    background =
      "hsla(" ++ (toString (round (model.value.hue * 360))) ++ ", 100%, 50%, 1)"

    color =
      model.value

    colorTransparent =
      (Ext.Color.toCSSRgba { color | alpha = 0 })

    colorFull =
      (Ext.Color.toCSSRgba { color | alpha = 1 })

    gradient =
      "linear-gradient(90deg, " ++ colorTransparent ++ "," ++ colorFull ++ ")"

    asPercent value =
      (toString (Ext.Number.roundTo 2 (value * 100))) ++ "%"

    action act =
      Ui.enabledActions
        model
        [ Drag.liftHandler act ]
  in
    node
      "ui-color-panel"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ node "ui-color-panel-hsv" []
        [ node "ui-color-panel-box" []
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
            [ node "ui-color-panel-alpha-background"
              [ style [ ( "background-image", gradient ) ] ] []
            , renderHandle "" (asPercent color.alpha)
            ]
        ]
      , Html.map Fields
          (ColorFields.view
            { fields
              | disabled = model.disabled
              , readonly = model.readonly
            })
      ]

{-| Sets the value of a color panel.

    ( updatedColorPanel, cmd ) = Ui.ColorPanel.setValue Color.black colorPanel
-}
setValue : Color -> Model -> ( Model, Cmd Msg )
setValue color model =
  let
    hsv =
      Ext.Color.toHsv color

    ( fields, cmd ) =
      ColorFields.setValue hsv model.fields
  in
    ( { model | value = hsv, fields = fields }, Cmd.map Fields cmd )


{-| Updates a color panel color by coordinates.
-}
updateValue : Hsv -> Model -> ( Model, Cmd Msg )
updateValue value model =
  if model.value == value then
    ( model, Cmd.none )
  else
    let
      (fields, cmd) =
        ColorFields.setValue value model.fields
    in
      ( { model | value = value, fields = fields }
      , Cmd.batch
        [ Emitter.send model.uid (encodeHsv value)
        , Cmd.map Fields cmd
        ]
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
    if model.alphaDrag == alphaDrag
    && model.hueDrag == hueDrag
    && model.drag == drag
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
