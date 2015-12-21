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
import Ui.NumberPad
import Ui.ColorPicker
import Ui.Image
import Ui

import Html.Attributes exposing (style, classList, colspan)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html exposing (div, text, node, table, tr, td)
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
  | Image Ui.Image.Action
  | NumberPad Ui.NumberPad.Action
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
     , image = Ui.Image.init "http://rs1371.pbsrc.com/albums/ag299/Victor_Binhara/Despicable%20Me/DespicableMe2_zpsc67ebdc5.jpg~c200"
     , numberRange = Ui.NumberRange.init 0
     , colorPanel = Ui.ColorPanel.init Color.blue
     , colorPicker = Ui.ColorPicker.init Color.yellow
     , numberPad = Ui.NumberPad.init 0
     , datePicker = { datePickerOptions | format = "%Y %B %e." }
     }, Effects.none)

render item =
  div [] [text item.label]

componentHeader title =
  tr [] [ td [colspan 3] [text title] ]

tableRow active readonly disabled =
  tr []
    [ td [] [ active   ]
    , td [] [ readonly ]
    , td [] [ disabled ]
    ]

view address model =
  let
    { chooser, colorPanel, datePicker, colorPicker
    , numberRange, slider, checkbox, checkbox2, checkbox3
    , calendar, inplaceInput, textarea, numberPad } = model
    numberPadVM =
      { bottomLeft = text ""
      , bottomRight = text "" }
  in
    Ui.App.view (forwardTo address App) model.app
      [ node "kitchen-sink" []
        [ Ui.title [] [text "Elm-UI Kitchen Sink"]
        , Ui.text "An opinionated UI library for the web in Elm, following
                   the Elm Architecture."
        , node "p" []
          [  Ui.IconButton.view address Nothing { side = "right"
                                                , text = "Get Started at Github"
                                                , kind = "Primary"
                                                , glyph = "social-github"
                                                , size = "big"
                                                , disabled = False } ]
        , Ui.subTitle [] [text "Components"]
        , Ui.text "The business logic for following components are
                   implemented fully in Elm, with minimal Native
                   bindings, following the Elm Architecture. Most
                   components implement disabled and readonly states."
        , table []
          [ tr [] [ td [] [text "Active"]
                  , td [] [text "Readonly"]
                  , td [] [text "Disabled"]
                  ]

          , componentHeader "Button"
          , tr []
            [ td [colspan 2]
              [ Ui.Container.row []
                [ Ui.Button.view address Nothing { text = "Primary"
                                                 , kind = "primary"
                                                 , size = "big"
                                                 , disabled = False }
                , Ui.Button.view address Nothing { text = "Secondary"
                                                 , kind = "secondary"
                                                 , size = "medium"
                                                 , disabled = False }
                , Ui.Button.view address Nothing { text = "Success"
                                                 , kind = "success"
                                                 , size = "medium"
                                                 , disabled = False }
                , Ui.Button.view address Nothing { text = "Warning"
                                                 , kind = "warning"
                                                 , size = "medium"
                                                 , disabled = False }
                , Ui.Button.view address Nothing { text = "Danger"
                                                 , kind = "danger"
                                                 , size = "small"
                                                 , disabled = False }
                ]
              ]
            , td []
                [ Ui.Button.view address Nothing { text = "Disabled"
                                                 , kind = "danger"
                                                 , size = "medium"
                                                 , disabled = True }
                ]
            ]

          , componentHeader "Icon Button"
          , tr []
            [ td [colspan 2]
              [ Ui.Container.row []
                [ Ui.IconButton.view address Nothing { side = "right"
                                                     , text = "Load"
                                                     , kind = "Primary"
                                                     , glyph = "android-download"
                                                     , size = "big"
                                                     , disabled = False }
                , Ui.IconButton.view address Nothing { side = "right"
                                                     , text = ""
                                                     , kind = "Primary"
                                                     , glyph = "archive"
                                                     , size = "medium"
                                                     , disabled = False }
                , Ui.IconButton.view address Nothing { side = "left"
                                                     , text = "Send"
                                                     , kind = "secondary"
                                                     , glyph = "arrow-left-c"
                                                     , size = "medium"
                                                     , disabled = False }
                , Ui.IconButton.view address Nothing { side = "right"
                                                     , text = "Success"
                                                     , kind = "success"
                                                     , glyph = "checkmark"
                                                     , size = "medium"
                                                     , disabled = False }
                , Ui.IconButton.view address Nothing { side = "right"
                                                     , text = "Warning"
                                                     , kind = "warning"
                                                     , glyph = "alert"
                                                     , size = "medium"
                                                     , disabled = False }
                , Ui.IconButton.view address Nothing { side = "right"
                                                     , text = "Danger"
                                                     , kind = "danger"
                                                     , glyph = "close"
                                                     , size = "small"
                                                     , disabled = False }
                ]
              ]
            , td []
              [ Ui.IconButton.view address Nothing { side = "left"
                                                   , text = "Disabled"
                                                   , kind = "success"
                                                   , glyph = "paper-airplane"
                                                   , size = "medium"
                                                   , disabled = True }
              ]
            ]

          , componentHeader "Calendar"
          , tableRow (Ui.Calendar.view (forwardTo address Calendar) calendar)
                     (Ui.Calendar.view (forwardTo address Calendar)
                       { calendar | readonly = True })
                     (Ui.Calendar.view (forwardTo address Calendar)
                       { calendar | disabled = True })

          , componentHeader "Checkbox"
          , tableRow (Ui.Checkbox.view (forwardTo address Checkbox) checkbox)
                     (Ui.Checkbox.view (forwardTo address Checkbox)
                       { checkbox | readonly = True })
                     (Ui.Checkbox.view (forwardTo address Checkbox)
                       { checkbox | disabled = True })
          , tableRow (Ui.Checkbox.toggleView (forwardTo address Checkbox2)
                       checkbox2)
                     (Ui.Checkbox.toggleView (forwardTo address Checkbox2)
                       { checkbox2 | readonly = True })
                     (Ui.Checkbox.toggleView (forwardTo address Checkbox2)
                       { checkbox2 | disabled = True })
          , tableRow (Ui.Checkbox.radioView (forwardTo address Checkbox3)
                       checkbox3)
                     (Ui.Checkbox.radioView (forwardTo address Checkbox3)
                       { checkbox3 | readonly = True })
                     (Ui.Checkbox.radioView (forwardTo address Checkbox3)
                       { checkbox3 | disabled = True })

          , componentHeader "Chooser"
          , tableRow (Ui.Chooser.view (forwardTo address Chooser) chooser)
                     (Ui.Chooser.view (forwardTo address Chooser)
                       { chooser | readonly = True })
                     (Ui.Chooser.view (forwardTo address Chooser)
                       { chooser | disabled = True })

          , componentHeader "Color Panel"
          , tableRow (Ui.ColorPanel.view (forwardTo address CP) colorPanel)
                     (Ui.ColorPanel.view (forwardTo address CP)
                       { colorPanel | readonly = True })
                     (Ui.ColorPanel.view (forwardTo address CP)
                       { colorPanel | disabled = True })

          , componentHeader "Color Picker"
          , tableRow (Ui.ColorPicker.view (forwardTo address CPP) colorPicker)
                     (Ui.ColorPicker.view (forwardTo address CPP)
                       { colorPicker | readonly = True })
                     (Ui.ColorPicker.view (forwardTo address CPP)
                       { colorPicker | disabled = True })

          , componentHeader "Date Picker"
          , tableRow (Ui.DatePicker.view (forwardTo address DP) datePicker)
                     (Ui.DatePicker.view (forwardTo address DP)
                       { datePicker | readonly = True })
                     (Ui.DatePicker.view (forwardTo address DP)
                       { datePicker | disabled = True })

          , componentHeader "Number Range"
          , tableRow (Ui.NumberRange.view (forwardTo address NR) numberRange)
                     (Ui.NumberRange.view (forwardTo address NR)
                       { numberRange | readonly = True })
                     (Ui.NumberRange.view (forwardTo address NR)
                       { numberRange | disabled = True })

          , componentHeader "Slider"
          , tableRow (Ui.Slider.view (forwardTo address Slider) slider)
                     (Ui.Slider.view (forwardTo address Slider)
                       { slider | readonly = True })
                     (Ui.Slider.view (forwardTo address Slider)
                       { slider | disabled = True })

          , componentHeader "Autogrow Textarea"
          , tableRow (Ui.Textarea.view (forwardTo address TA) textarea)
                     (Ui.Textarea.view (forwardTo address TA)
                       { textarea | readonly = True })
                     (Ui.Textarea.view (forwardTo address TA)
                       { textarea | disabled = True })

          , componentHeader "Inplace Input"
          , tableRow (Ui.InplaceInput.view (forwardTo address InplaceInput)
                       inplaceInput)
                     (Ui.InplaceInput.view (forwardTo address InplaceInput)
                       { inplaceInput | readonly = True })
                     (Ui.InplaceInput.view (forwardTo address InplaceInput)
                       { inplaceInput | disabled = True })

          , componentHeader "Number Pad"
          , tableRow (Ui.NumberPad.view (forwardTo address NumberPad)
                       numberPadVM numberPad)
                     (Ui.NumberPad.view (forwardTo address NumberPad)
                       numberPadVM { numberPad | readonly = True })
                     (Ui.NumberPad.view (forwardTo address NumberPad)
                       numberPadVM { numberPad | disabled = True })

          , componentHeader "Image"
          , tr []
            [ td [colspan 3]
              [ Ui.Image.view (forwardTo address Image) model.image ]
            ]
          ]
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
    Image act ->
      ({ model | image = Ui.Image.update act model.image}, Effects.none)
    NumberPad act ->
      ({ model | numberPad = Ui.NumberPad.update act model.numberPad}, Effects.none)

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
