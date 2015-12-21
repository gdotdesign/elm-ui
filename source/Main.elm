import Signal exposing (forwardTo)
import Ext.Date
import StartApp
import Effects
import Mouse
import Color
import Task

import Html.Attributes exposing (style, classList, colspan, href)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html exposing (div, text, node, table, tr, td)
import Debug exposing (log)

import Ui.InplaceInput
import Ui.NumberRange
import Ui.ColorPicker
import Ui.DatePicker
import Ui.ColorPanel
import Ui.IconButton
import Ui.NumberPad
import Ui.Container
import Ui.Calendar
import Ui.Checkbox
import Ui.Textarea
import Ui.Chooser
import Ui.Button
import Ui.Slider
import Ui.Image
import Ui.App

import Ui.DropdownMenu

import Ui

type Action
  = InplaceInput Ui.InplaceInput.Action
  | NumberRange Ui.NumberRange.Action
  | ColorPicker Ui.ColorPicker.Action
  | ColorPanel Ui.ColorPanel.Action
  | DatePicker Ui.DatePicker.Action
  | NumberPad Ui.NumberPad.Action
  | Checkbox2 Ui.Checkbox.Action
  | Checkbox3 Ui.Checkbox.Action
  | TextArea Ui.Textarea.Action
  | Calendar Ui.Calendar.Action
  | Checkbox Ui.Checkbox.Action
  | Chooser Ui.Chooser.Action
  | Slider Ui.Slider.Action
  | Image Ui.Image.Action
  | App Ui.App.Action
  | MousePosition (Int, Int)
  | MouseIsDown Bool
  | Open String
  | Nothing

  | DropdownMenu Ui.DropdownMenu.Action

type alias Model =
  { app : Ui.App.Model
  , datePicker : Ui.DatePicker.Model
  , inplaceInput : Ui.InplaceInput.Model
  , colorPicker : Ui.ColorPicker.Model
  , numberRange : Ui.NumberRange.Model
  , colorPanel : Ui.ColorPanel.Model
  , numberPad : Ui.NumberPad.Model
  , checkbox3 : Ui.Checkbox.Model
  , checkbox2 : Ui.Checkbox.Model
  , checkbox : Ui.Checkbox.Model
  , textarea : Ui.Textarea.Model
  , calendar : Ui.Calendar.Model
  , chooser : Ui.Chooser.Model
  , slider : Ui.Slider.Model
  , image : Ui.Image.Model

  , menu : Ui.DropdownMenu.Model
  }

init : Model
init =
  let
    datePickerOptions = Ui.DatePicker.init Ext.Date.now
  in
    { app = Ui.App.init "Elm-UI Kitchen Sink"
    , datePicker = { datePickerOptions | format = "%Y %B %e." }
    , chooser = Ui.Chooser.init data "Select a country..." ""
    , inplaceInput = Ui.InplaceInput.init "Test Value"
    , colorPicker = Ui.ColorPicker.init Color.yellow
    , colorPanel = Ui.ColorPanel.init Color.blue
    , calendar = Ui.Calendar.init Ext.Date.now
    , numberRange = Ui.NumberRange.init 0
    , checkbox3 = Ui.Checkbox.init False
    , checkbox2 = Ui.Checkbox.init False
    , checkbox = Ui.Checkbox.init False
    , textarea = Ui.Textarea.init "Test"
    , numberPad = Ui.NumberPad.init 0
    , image = Ui.Image.init imageUrl
    , slider = Ui.Slider.init 50

    , menu = Ui.DropdownMenu.init
    }

data : List Ui.Chooser.Item
data =
  [ { label = "Hungary",                      value = "0" }
  , { label = "Germany",                      value = "1" }
  , { label = "French" ,                      value = "2" }
  , { label = "Italy"  ,                      value = "3" }
  , { label = "Russia" ,                      value = "4" }
  , { label = "Some very long named country", value = "5" }
  ]

imageUrl : String
imageUrl =
  "http://rs1371.pbsrc.com/albums/ag299/Victor_Binhara/Despicable%20Me/DespicableMe2_zpsc67ebdc5.jpg~c200"

componentHeader : String -> Html.Html
componentHeader title =
  tr [] [ td [colspan 3] [text title] ]

tableRow : Html.Html -> Html.Html -> Html.Html -> Html.Html
tableRow active readonly disabled =
  tr []
    [ td [] [ active   ]
    , td [] [ readonly ]
    , td [] [ disabled ]
    ]

view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    { chooser, colorPanel, datePicker, colorPicker, numberRange, slider
    , checkbox, checkbox2, checkbox3, calendar, inplaceInput, textarea
    , numberPad } = model

    numberPadViewModel =
      { bottomLeft = text ""
      , bottomRight = text ""
      }
  in
    Ui.App.view (forwardTo address App) model.app
      [ node "kitchen-sink" []
        [ Ui.title [] [text "Elm-UI Kitchen Sink"]
        , Ui.text "An opinionated UI library for the web in Elm, following
                   the Elm Architecture."
        , node "p" []
          [ Ui.IconButton.view
              address
              (Open "https://github.com/gdotdesign/elm-ui")
              { side = "right"
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
                [ Ui.DropdownMenu.view
                  (forwardTo address DropdownMenu)
                  (Ui.Button.view address Nothing { text = "Primary"
                                                  , kind = "primary"
                                                  , size = "big"
                                                  , disabled = False })
                  [text "asd"]
                  model.menu
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
          , tableRow (Ui.Calendar.view (forwardTo address Calendar)
                       calendar)
                     (Ui.Calendar.view (forwardTo address Calendar)
                       { calendar | readonly = True })
                     (Ui.Calendar.view (forwardTo address Calendar)
                       { calendar | disabled = True })

          , componentHeader "Checkbox"
          , tableRow (Ui.Checkbox.view (forwardTo address Checkbox)
                       checkbox)
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
          , tableRow (Ui.Chooser.view (forwardTo address Chooser)
                       chooser)
                     (Ui.Chooser.view (forwardTo address Chooser)
                       { chooser | readonly = True })
                     (Ui.Chooser.view (forwardTo address Chooser)
                       { chooser | disabled = True })

          , componentHeader "Color Panel"
          , tableRow (Ui.ColorPanel.view (forwardTo address ColorPanel)
                       colorPanel)
                     (Ui.ColorPanel.view (forwardTo address ColorPanel)
                       { colorPanel | readonly = True })
                     (Ui.ColorPanel.view (forwardTo address ColorPanel)
                       { colorPanel | disabled = True })

          , componentHeader "Color Picker"
          , tableRow (Ui.ColorPicker.view (forwardTo address ColorPicker)
                       colorPicker)
                     (Ui.ColorPicker.view (forwardTo address ColorPicker)
                       { colorPicker | readonly = True })
                     (Ui.ColorPicker.view (forwardTo address ColorPicker)
                       { colorPicker | disabled = True })

          , componentHeader "Date Picker"
          , tableRow (Ui.DatePicker.view (forwardTo address DatePicker)
                       datePicker)
                     (Ui.DatePicker.view (forwardTo address DatePicker)
                       { datePicker | readonly = True })
                     (Ui.DatePicker.view (forwardTo address DatePicker)
                       { datePicker | disabled = True })

          , componentHeader "Number Range"
          , tableRow (Ui.NumberRange.view (forwardTo address NumberRange)
                       numberRange)
                     (Ui.NumberRange.view (forwardTo address NumberRange)
                       { numberRange | readonly = True })
                     (Ui.NumberRange.view (forwardTo address NumberRange)
                       { numberRange | disabled = True })

          , componentHeader "Slider"
          , tableRow (Ui.Slider.view (forwardTo address Slider)
                       slider)
                     (Ui.Slider.view (forwardTo address Slider)
                       { slider | readonly = True })
                     (Ui.Slider.view (forwardTo address Slider)
                       { slider | disabled = True })

          , componentHeader "Autogrow Textarea"
          , tableRow (Ui.Textarea.view (forwardTo address TextArea)
                       textarea)
                     (Ui.Textarea.view (forwardTo address TextArea)
                       { textarea | readonly = True })
                     (Ui.Textarea.view (forwardTo address TextArea)
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
                       numberPadViewModel numberPad)
                     (Ui.NumberPad.view (forwardTo address NumberPad)
                       numberPadViewModel { numberPad | readonly = True })
                     (Ui.NumberPad.view (forwardTo address NumberPad)
                       numberPadViewModel { numberPad | disabled = True })

          , componentHeader "Image"
          , tr []
            [ td []
              [ Ui.Image.view (forwardTo address Image) model.image ]
            , td [] []
            , td [] []
            ]
          ]
      ]
    ]

fxNone : Model -> (Model, Effects.Effects Action)
fxNone model =
  (model, Effects.none)

update : Action -> Model -> Model
update action model =
  case action of
    InplaceInput act ->
      { model | inplaceInput = Ui.InplaceInput.update act model.inplaceInput }
    NumberRange act ->
      { model | numberRange = Ui.NumberRange.update act model.numberRange    }
    ColorPicker act ->
      { model | colorPicker = Ui.ColorPicker.update act model.colorPicker    }
    DatePicker act ->
      { model | datePicker = Ui.DatePicker.update act model.datePicker       }
    ColorPanel act ->
      { model | colorPanel = Ui.ColorPanel.update act model.colorPanel       }
    NumberPad act ->
      { model | numberPad = Ui.NumberPad.update act model.numberPad          }
    Checkbox2 act ->
      { model | checkbox2 = Ui.Checkbox.update act model.checkbox2           }
    Checkbox3 act ->
      { model | checkbox3 = Ui.Checkbox.update act model.checkbox3           }
    Checkbox act ->
      { model | checkbox = Ui.Checkbox.update act model.checkbox             }
    TextArea act ->
      { model | textarea = Ui.Textarea.update act model.textarea             }
    Calendar act ->
      { model | calendar = Ui.Calendar.update act model.calendar             }
    Chooser act ->
      { model | chooser = Ui.Chooser.update act model.chooser                }
    Slider act ->
      { model | slider = Ui.Slider.update act model.slider                   }
    Image act ->
      { model | image = Ui.Image.update act model.image                      }
    App act ->
      case act of
        Ui.App.Scrolled ->
          { model | menu = Ui.DropdownMenu.close model.menu }
        _ ->
          { model | app = Ui.App.update act model.app                        }

    MouseIsDown value ->
      { model
        | numberRange = Ui.NumberRange.handleClick value model.numberRange
        , colorPanel = Ui.ColorPanel.handleClick value model.colorPanel
        , colorPicker = Ui.ColorPicker.handleClick value model.colorPicker
        , slider = Ui.Slider.handleClick value model.slider
        , menu = Ui.DropdownMenu.handleClick value model.menu
        }
    MousePosition (x,y) ->
      { model
        | numberRange = Ui.NumberRange.handleMove x y model.numberRange
        , colorPicker = Ui.ColorPicker.handleMove x y model.colorPicker
        , colorPanel = Ui.ColorPanel.handleMove x y model.colorPanel
        , slider = Ui.Slider.handleMove x y model.slider
        }

    Open url ->
      Ui.open url model

    DropdownMenu act ->
      { model | menu = Ui.DropdownMenu.update act model.menu }

    Nothing ->
      model

update' : Action -> Model -> (Model, Effects.Effects Action)
update' action model =
  update action model
    |> fxNone

app =
  StartApp.start { init = (init, Effects.none)
                 , view = view
                 , update = update'
                 , inputs = [ Signal.map MousePosition Mouse.position
                            , Signal.map MouseIsDown Mouse.isDown
                            ]
                 }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
