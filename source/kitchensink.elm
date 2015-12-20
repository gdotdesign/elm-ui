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
  | MousePosition (Int, Int)
  | MouseIsDown Bool
  | DP Ui.DatePicker.Action
  | TA Ui.Textarea.Action
  | Checkbox Ui.Checkbox.Action
  | Checkbox2 Ui.Checkbox.Action
  | Checkbox3 Ui.Checkbox.Action
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
     , checkbox2 = Ui.Checkbox.init False
     , checkbox3 = Ui.Checkbox.init False
     , inplaceInput = Ui.InplaceInput.init "Test Value"
     , numberRange = Ui.NumberRange.init 0
     , colorPanel = Ui.ColorPanel.init Color.blue
     , colorPicker = Ui.ColorPicker.init Color.yellow
     , datePicker = { datePickerOptions | format = "%Y %B %e." }
     }, Effects.none)

render item =
  div [] [text item.label]

view address model =
  let
    { chooser, colorPanel, datePicker, colorPicker
    , numberRange, slider, checkbox, checkbox2, checkbox3
    , calendar } = model
  in
    Ui.App.view (forwardTo address App) model.app
      [ Ui.panel []
        [ node "h2" [] [text "Button"]
        , Ui.Container.row []
          [ Ui.Button.view address Nothing { text = "Primary"
                                           , kind = "primary"
                                           , disabled = False }
          , Ui.Button.view address Nothing { text = "Success"
                                           , kind = "success"
                                           , disabled = False }
          , Ui.Button.view address Nothing { text = "Warning"
                                           , kind = "warning"
                                           , disabled = False }
          , Ui.Button.view address Nothing { text = "Danger"
                                           , kind = "danger"
                                           , disabled = False }
          , Ui.Button.view address Nothing { text = "Disabled"
                                           , kind = "danger"
                                           , disabled = True }
          ]

        , node "h2" [] [text "Icon Button"]
        , Ui.Container.row []
          [ Ui.IconButton.view address Nothing { side = "right"
                                               , text = "Primary"
                                               , kind = "Primary"
                                               , glyph = "android-download"
                                               , disabled = False }
          , Ui.IconButton.view address Nothing { side = "right"
                                               , text = ""
                                               , kind = "Primary"
                                               , glyph = "archive"
                                               , disabled = False }
          , Ui.IconButton.view address Nothing { side = "right"
                                               , text = "Success"
                                               , kind = "success"
                                               , glyph = "checkmark"
                                               , disabled = False }
          , Ui.IconButton.view address Nothing { side = "right"
                                               , text = "Warning"
                                               , kind = "warning"
                                               , glyph = "alert"
                                               , disabled = False }
          , Ui.IconButton.view address Nothing { side = "right"
                                               , text = "Danger"
                                               , kind = "danger"
                                               , glyph = "close"
                                               , disabled = False }
          , Ui.IconButton.view address Nothing { side = "left"
                                               , text = "Disabled"
                                               , kind = "success"
                                               , glyph = "paper-airplane"
                                               , disabled = True }
          ]

        , node "h2" [] [text "Calendar"]
        , Ui.Container.row []
          [ Ui.Calendar.view (forwardTo address Calendar) calendar
          , Ui.Calendar.view (forwardTo address Calendar)
              { calendar | readonly = True }
          , Ui.Calendar.view (forwardTo address Calendar)
              { calendar | disabled = True }
          ]

        , node "h2" [] [text "Checkbox"]
        , Ui.Container.column []
          [ Ui.Container.row []
            [ Ui.Checkbox.view (forwardTo address Checkbox) checkbox
            , Ui.Checkbox.view (forwardTo address Checkbox)
                { checkbox | readonly = True }
            , Ui.Checkbox.view (forwardTo address Checkbox)
                { checkbox | disabled = True }
            ]
          , Ui.Container.row []
            [ Ui.Checkbox.toggleView (forwardTo address Checkbox2) checkbox2
            , Ui.Checkbox.toggleView (forwardTo address Checkbox2)
                { checkbox2 | readonly = True }
            , Ui.Checkbox.toggleView (forwardTo address Checkbox2)
                { checkbox2 | disabled = True }
            ]
          , Ui.Container.row []
            [ Ui.Checkbox.radioView (forwardTo address Checkbox3) checkbox3
            , Ui.Checkbox.radioView (forwardTo address Checkbox3)
                { checkbox3 | readonly = True }
            , Ui.Checkbox.radioView (forwardTo address Checkbox3)
                { checkbox3 | disabled = True }
            ]
          ]

        , node "h2" [] [text "Chooser"]
        , Ui.Container.row []
          [ Ui.Chooser.view (forwardTo address Chooser) chooser
          , Ui.Chooser.view (forwardTo address Chooser)
              { chooser | readonly = True }
          , Ui.Chooser.view (forwardTo address Chooser)
              { chooser | disabled = True }
          ]

        , node "h2" [] [text "Color Panel"]
        , Ui.Container.row []
          [ Ui.ColorPanel.view (forwardTo address CP) colorPanel
          , Ui.ColorPanel.view (forwardTo address CP)
              { colorPanel | readonly = True }
          , Ui.ColorPanel.view (forwardTo address CP)
              { colorPanel | disabled = True }
          ]

        , node "h2" [] [text "Color Picker"]
        , Ui.Container.row []
          [ Ui.ColorPicker.view (forwardTo address CPP) colorPicker
          , Ui.ColorPicker.view (forwardTo address CPP)
              { colorPicker | readonly = True }
          , Ui.ColorPicker.view (forwardTo address CPP)
              { colorPicker | disabled = True }
          ]

        , node "h2" [] [text "Date Picker"]
        , Ui.Container.row []
          [ Ui.DatePicker.view (forwardTo address DP) datePicker
          , Ui.DatePicker.view (forwardTo address DP)
              { datePicker | readonly = True }
          , Ui.DatePicker.view (forwardTo address DP)
              { datePicker | disabled = True }
          ]

        , node "h2" [] [text "Number Range"]
        , Ui.Container.row []
          [ Ui.NumberRange.view (forwardTo address NR) numberRange
          , Ui.NumberRange.view (forwardTo address NR)
              { numberRange | readonly = True }
          , Ui.NumberRange.view (forwardTo address NR)
              { numberRange | disabled = True }
          ]

        , node "h2" [] [text "Slider"]
        , Ui.Container.row []
          [ Ui.Slider.view (forwardTo address Slider) slider
          , Ui.Slider.view (forwardTo address Slider)
            { slider | readonly = True }
          , Ui.Slider.view (forwardTo address Slider)
            { slider | disabled = True }
          ]

        , node "h2" [] [text "Autogrow Textarea"]
        , Ui.Textarea.view (forwardTo address TA)
            model.textarea

        , node "h2" [] [text "Inplace Input"]
        , Ui.InplaceInput.view (forwardTo address InplaceInput)
            model.inplaceInput
        ]
      ]

update action model =
  case action of
    Checkbox act ->
      ({ model | checkbox = Ui.Checkbox.update act model.checkbox }, Effects.none)
    Checkbox2 act ->
      ({ model | checkbox2 = Ui.Checkbox.update act model.checkbox2 }, Effects.none)
    Checkbox3 act ->
      ({ model | checkbox3 = Ui.Checkbox.update act model.checkbox3 }, Effects.none)
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)


    MouseIsDown value ->
      ({ model | slider = Ui.Slider.handleClick value model.slider
               , numberRange = Ui.NumberRange.handleClick value model.numberRange
               , colorPanel = Ui.ColorPanel.handleClick value model.colorPanel
               , colorPicker = Ui.ColorPicker.handleClick value model.colorPicker }, Effects.none)
    MousePosition (x,y) ->
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
                   , inputs = [Signal.map MousePosition Mouse.position,
                              Signal.map MouseIsDown Mouse.isDown] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
