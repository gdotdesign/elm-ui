import StartApp
import Effects
import Signal exposing (forwardTo)
import Task

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
  | Slider2 Ui.Slider.Action
  | MP (Int, Int)
  | IsDown Bool
  | DP Ui.DatePicker.Action
  | TA Ui.Textarea.Action
  | Checkbox Ui.Checkbox.Action
  | Checkbox2 Ui.Checkbox.Action
  | InplaceInput Ui.InplaceInput.Action
  | NR Ui.NumberRange.Action
  | Nothing

data =
  [ { label = "Hungary", value = "0" }
  , { label = "Germany", value = "1" }
  , { label = "French", value = "2" }
  , { label = "Italy", value = "3" }
  , { label = "Russia", value = "4" }
  ]

init =
  let
    s2 = Ui.Slider.init 50
    datePickerOptions = Ui.DatePicker.init Ext.Date.now
  in
    ({ app = Ui.App.init
     , chooser = Ui.Chooser.init data "Select a country..." ""
     , calendar = Ui.Calendar.init Ext.Date.now
     , draggable = Ui.Slider.init 0
     , textarea = Ui.Textarea.init "Test"
     , slider = { s2 | disabled = False }
     , checkbox = Ui.Checkbox.init False
     , checkbox2 = { disabled = True, value = True }
     , inplaceInput = Ui.InplaceInput.init "Test Value"
     , numberRange = Ui.NumberRange.init 0
     , datePicker = { datePickerOptions | format = "%Y %B %e." } }, Effects.none)

render item =
  div [] [text item.label]

view address model =
  Ui.App.view (forwardTo address App) model.app
    [ Ui.panel []
      [ node "h2" [] [text "Buttons"]
      , Ui.Container.view { align = "start", direction = "row", compact = False} []
        [ Ui.Button.view address Nothing { text = "Test", kind = "primary", disabled = False }
        , Ui.Button.view address Nothing { text = "Disabled", kind = "danger", disabled = True }
        , Ui.IconButton.view address Nothing { side = "left", text = "Download", kind = "success", glyph = "android-download", disabled = False }
        ]
      , node "h2" [] [text "Checkbox"]
      , Ui.Container.view { align = "start", direction = "row", compact = False} []
        [ Ui.Checkbox.view (forwardTo address Checkbox) model.checkbox
        , Ui.Checkbox.view (forwardTo address Checkbox2) model.checkbox2
        ]
      , Ui.Container.view { align = "start", direction = "row", compact = False} []
        [ Ui.Checkbox.toggleView (forwardTo address Checkbox) model.checkbox
        , Ui.Checkbox.toggleView (forwardTo address Checkbox2) model.checkbox2
        ]
      , node "h2" [] [text "Inplace Input"]
      , Ui.InplaceInput.view (forwardTo address InplaceInput) model.inplaceInput
      , node "h2" [] [text "Number Range"]
      , Ui.NumberRange.view (forwardTo address NR) model.numberRange
      , node "h2" [] [text "Slider"]
      , Ui.Slider.view (forwardTo address Slider) model.draggable
      , Ui.Slider.view (forwardTo address Slider2) model.slider
      , node "h2" [] [text "Chooser"]
      , Ui.Chooser.view (forwardTo address Chooser) model.chooser
      , node "h2" [] [text "Date Picker"]
      , Ui.DatePicker.view (forwardTo address DP) model.datePicker
      , node "h2" [] [text "Autogrow Textarea"]
      , Ui.Textarea.view (forwardTo address TA) model.textarea
      , node "h2" [] [text "Calendar"]
      , Ui.Calendar.view (forwardTo address Calendar) model.calendar
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
               , draggable = Ui.Slider.handleClick value model.draggable
               , numberRange = Ui.NumberRange.handleClick value model.numberRange }, Effects.none)
    MP (x,y) ->
      ({ model | slider = Ui.Slider.handleMove x y model.slider
               , draggable = Ui.Slider.handleMove x y model.draggable
               , numberRange = Ui.NumberRange.handleMove x y model.numberRange}, Effects.none)


    Chooser act ->
      ({ model | chooser = Ui.Chooser.update act model.chooser }, Effects.none)
    Calendar act ->
      ({ model | calendar = Ui.Calendar.update act model.calendar}, Effects.none)
    Slider act ->
      ({ model | draggable = Ui.Slider.update act model.draggable}, Effects.none)
    Slider2 act ->
      ({ model | slider = Ui.Slider.update act model.slider}, Effects.none)
    NR act ->
      ({ model | numberRange = Ui.NumberRange.update act model.numberRange}, Effects.none)
    DP act ->
      ({ model | datePicker = Ui.DatePicker.update act model.datePicker}, Effects.none)
    TA act ->
      ({ model | textarea = Ui.Textarea.update act model.textarea}, Effects.none)
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
