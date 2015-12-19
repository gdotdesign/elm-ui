import StartApp
import Effects
import Signal exposing (forwardTo)
import Task
import Color

import Ui.App
import Ui.Button
import Ui.Calendar
import Ui.Checkbox
import Ui.Chooser
import Ui.Container
import Ui.DatePicker
import Ui.IconButton
import Ui.Slider
import Ui.Textarea
import Ui.InplaceInput
import Ui.NumberRange
import Ui.ColorPanel
import Ui.ColorPicker
import Ui

import Html.Attributes exposing (style, classList)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html exposing (div, text, node)
import Debug exposing (log)

import Ext.Date

import Mouse

type Action
  = App Ui.App.Action
  | Chooser Ui.Chooser.Action
  | Calendar Ui.Calendar.Action
  | Slider Ui.Slider.Action
  | MP (Int, Int)
  | IsDown Bool
  | DP Ui.DatePicker.Action
  | TA Ui.Textarea.Action
  | Checkbox Ui.Checkbox.Action
  | Checkbox2 Ui.Checkbox.Action
  | InplaceInput Ui.InplaceInput.Action
  | NR Ui.NumberRange.Action
  | CP Ui.ColorPanel.Action
  | CPP Ui.ColorPicker.Action
  | Nothing

data =
  [ { label = "Hungary", value = "0" }
  , { label = "Germany", value = "1" }
  , { label = "French", value = "2" }
  , { label = "Italy", value = "3" }
  , { label = "Russia", value = "4" }
  , { label = "Some very long named country", value = "5" }
  ]

init =
  let
    datePickerOptions = Ui.DatePicker.init Ext.Date.now
  in
    ({ app = Ui.App.init
     , chooser = Ui.Chooser.init data "Select a country..." ""
     , calendar = Ui.Calendar.init Ext.Date.now
     , textarea = Ui.Textarea.init "Test"
     , slider = Ui.Slider.init 50
     , checkbox = Ui.Checkbox.init False
     , checkbox2 = { disabled = True, value = True }
     , inplaceInput = Ui.InplaceInput.init "Test Value"
     , numberRange = Ui.NumberRange.init 0
     , colorPanel = Ui.ColorPanel.init Color.blue
     , colorPicker = Ui.ColorPicker.init Color.yellow
     , datePicker = { datePickerOptions | format = "%Y %B %e." } }, Effects.none)

render item =
  div [] [text item.label]

view address model =
  let
    { chooser, colorPanel, datePicker, colorPicker
    , numberRange, slider } = model
  in
    Ui.App.view (forwardTo address App) model.app
      [ Ui.panel []
        [ node "h2" [] [text "Buttons"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.Button.view address Nothing { text = "Test", kind = "primary", disabled = False }
          , Ui.IconButton.view address Nothing { side = "left", text = "Download", kind = "success", glyph = "android-download", disabled = False }
          , Ui.Button.view address Nothing { text = "Disabled", kind = "danger", disabled = True }
          ]
        , node "h2" [] [text "Checkbox"]
        , Ui.Container.view { align = "start", direction = "column", compact = False} []
          [ Ui.Container.view { align = "start", direction = "row", compact = False} []
            [ Ui.Checkbox.view (forwardTo address Checkbox) model.checkbox
            , Ui.Checkbox.view (forwardTo address Checkbox2) model.checkbox2
            ]
          , Ui.Container.view { align = "start", direction = "row", compact = False} []
            [ Ui.Checkbox.toggleView (forwardTo address Checkbox) model.checkbox
            , Ui.Checkbox.toggleView (forwardTo address Checkbox2) model.checkbox2
            ]
          , Ui.Container.view { align = "start", direction = "row", compact = False} []
            [ Ui.Checkbox.radioView (forwardTo address Checkbox) model.checkbox
            , Ui.Checkbox.radioView (forwardTo address Checkbox2) model.checkbox2
            ]
          ]
        , node "h2" [] [text "Color Panel"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.ColorPanel.view (forwardTo address CP) colorPanel
          , Ui.ColorPanel.view (forwardTo address CP) { colorPanel | disabled = True }
          ]
        , node "h2" [] [text "Color Picker"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.ColorPicker.view (forwardTo address CPP) colorPicker
          , Ui.ColorPicker.view (forwardTo address CPP) { colorPicker | disabled = True }
          ]
        , node "h2" [] [text "Number Range"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.NumberRange.view (forwardTo address NR) numberRange
          , Ui.NumberRange.view (forwardTo address NR) { numberRange | disabled = True }
          ]
        , node "h2" [] [text "Slider"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.Slider.view (forwardTo address Slider) slider
          , Ui.Slider.view (forwardTo address Slider) { slider | disabled = True }
          ]
        , node "h2" [] [text "Chooser"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.Chooser.view (forwardTo address Chooser) chooser
          , Ui.Chooser.view (forwardTo address Chooser) { chooser | disabled = True }
          ]
        , node "h2" [] [text "Date Picker"]
        , Ui.Container.view { align = "start", direction = "row", compact = False} []
          [ Ui.DatePicker.view (forwardTo address DP) datePicker
          , Ui.DatePicker.view (forwardTo address DP) { datePicker | disabled = True }
          ]
        , node "h2" [] [text "Autogrow Textarea"]
        , Ui.Textarea.view (forwardTo address TA) model.textarea
        , node "h2" [] [text "Calendar"]
        , Ui.Calendar.view (forwardTo address Calendar) model.calendar
        , node "h2" [] [text "Inplace Input"]
        , Ui.InplaceInput.view (forwardTo address InplaceInput) model.inplaceInput
        ]
      ]

update action model =
  case action of
    Checkbox act ->
      ({ model | checkbox = Ui.Checkbox.update act model.checkbox }, Effects.none)
    Checkbox2 act ->
      ({ model | checkbox2 = Ui.Checkbox.update act model.checkbox2 }, Effects.none)
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)


    IsDown value ->
      ({ model | slider = Ui.Slider.handleClick value model.slider
               , numberRange = Ui.NumberRange.handleClick value model.numberRange
               , colorPanel = Ui.ColorPanel.handleClick value model.colorPanel
               , colorPicker = Ui.ColorPicker.handleClick value model.colorPicker }, Effects.none)
    MP (x,y) ->
      ({ model | slider = Ui.Slider.handleMove x y model.slider
               , numberRange = Ui.NumberRange.handleMove x y model.numberRange
               , colorPanel = Ui.ColorPanel.handleMove x y model.colorPanel
               , colorPicker = Ui.ColorPicker.handleMove x y model.colorPicker }, Effects.none)


    Chooser act ->
      ({ model | chooser = Ui.Chooser.update act model.chooser }, Effects.none)
    Calendar act ->
      ({ model | calendar = Ui.Calendar.update act model.calendar}, Effects.none)
    Slider act ->
      ({ model | slider = Ui.Slider.update act model.slider}, Effects.none)
    NR act ->
      ({ model | numberRange = Ui.NumberRange.update act model.numberRange}, Effects.none)
    DP act ->
      ({ model | datePicker = Ui.DatePicker.update act model.datePicker}, Effects.none)
    TA act ->
      ({ model | textarea = Ui.Textarea.update act model.textarea}, Effects.none)
    CP act ->
      ({ model | colorPanel = Ui.ColorPanel.update act model.colorPanel}, Effects.none)
    CPP act ->
      ({ model | colorPicker = Ui.ColorPicker.update act model.colorPicker}, Effects.none)
    InplaceInput act ->
      ({ model | inplaceInput = Ui.InplaceInput.update act model.inplaceInput}, Effects.none)
    Nothing ->
      (model, Effects.none)

app =
  let
    (state, effect) = init
  in
    StartApp.start { init = (state, effect)
                   , view = view
                   , update = update
                   , inputs = [Signal.map MP Mouse.position,
                              Signal.map IsDown Mouse.isDown] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
