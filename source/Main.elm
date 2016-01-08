import Signal exposing (forwardTo)
import Ext.Date
import StartApp
import Keyboard
import Effects
import Mouse
import Color
import Task
import Date

import Html.Attributes exposing (style, classList, colspan, href)
import Html.Events exposing (onClick)
import Html exposing (div, text, node, table, tr, td)
import Debug exposing (log)

import Ui.NotificationCenter
import Ui.DropdownMenu
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
import Ui.Modal
import Ui.Image
import Ui.App
import Ui

type Action
  = InplaceInput Ui.InplaceInput.Action
  | DropdownMenu Ui.DropdownMenu.Action
  | NumberRange Ui.NumberRange.Action
  | ColorPicker Ui.ColorPicker.Action
  | ColorPanel Ui.ColorPanel.Action
  | DatePicker Ui.DatePicker.Action
  | NumberPad Ui.NumberPad.Action
  | Notis Ui.NotificationCenter.Action
  | Checkbox2 Ui.Checkbox.Action
  | Checkbox3 Ui.Checkbox.Action
  | TextArea Ui.Textarea.Action
  | Calendar Ui.Calendar.Action
  | Checkbox Ui.Checkbox.Action
  | Chooser Ui.Chooser.Action
  | Slider Ui.Slider.Action
  | Image Ui.Image.Action
  | Modal Ui.Modal.Action
  | App Ui.App.Action
  | MousePosition (Int, Int)
  | MouseIsDown Bool
  | ShowNotification
  | EscIsDown Bool
  | Open String
  | CloseMenu
  | CloseModal
  | OpenModal
  | Nothing
  | Alert

type alias Model =
  { app : Ui.App.Model
  , notifications : Ui.NotificationCenter.Model
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
  , menu : Ui.DropdownMenu.Model
  , chooser : Ui.Chooser.Model
  , slider : Ui.Slider.Model
  , modal : Ui.Modal.Model
  , image : Ui.Image.Model
  , clicked : Bool
  }

init : Model
init =
  let
    datePickerOptions = Ui.DatePicker.init (Ext.Date.now ())
  in
    { app = Ui.App.init "Elm-UI Kitchen Sink"
    , notifications = Ui.NotificationCenter.init 4000 320
    , datePicker = { datePickerOptions | format = "%Y %B %e." }
    , chooser = Ui.Chooser.init data "Select a country..." ""
    , inplaceInput = Ui.InplaceInput.init "Test Value"
    , colorPicker = Ui.ColorPicker.init Color.yellow
    , colorPanel = Ui.ColorPanel.init Color.blue
    , calendar = Ui.Calendar.init (Ext.Date.createDate 2015 5 1)
    , numberRange = Ui.NumberRange.init 0
    , checkbox3 = Ui.Checkbox.init False
    , checkbox2 = Ui.Checkbox.init False
    , checkbox = Ui.Checkbox.init False
    , textarea = Ui.Textarea.init "Test"
    , numberPad = Ui.NumberPad.init 0
    , image = Ui.Image.init imageUrl
    , slider = Ui.Slider.init 50
    , menu = Ui.DropdownMenu.init
    , modal = Ui.Modal.init
    , clicked = False
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

    clicked =
      if model.clicked then [node "clicked" [] [text ""]] else []

    numberPadViewModel =
      { bottomLeft = text ""
      , bottomRight = text ""
      }
  in
    Ui.App.view (forwardTo address App) model.app
      [ Ui.NotificationCenter.view (forwardTo address Notis) model.notifications
      , Ui.Modal.view
        (forwardTo address Modal)
        { title = "Test Modal"
        , content =
          [ node "p" [] [text "This is a modal window."]
          , node "p" [] [text "Lorem ipsum dolor sit amet, consectetur
                               adipiscing elit. Pellentesque ornare odio sed
                               lorem malesuada, id efficitur elit consequat.
                               Aenean suscipit, est a varius aliquam,
                               turpis diam sollicitudin tortor, in venenatis
                               felis nisl ac ex. Quisque finibus nisl nec urna
                               laoreet aliquet. Maecenas et volutpat arcu, a
                               dapibus tellus. Praesent nec enim velit. Class
                               aptent taciti sociosqu ad litora torquent per
                               conubia nostra, per inceptos himenaeos. Nullam
                               volutpat turpis vel lorem fringilla, pulvinar
                               viverra dolor varius."]
          ]
        , footer =
          [ Ui.Container.rowEnd []
            [ Ui.Button.primary "Close" address CloseModal ]
          ]
        }
        model.modal
      , node "kitchen-sink" []
        [ Ui.title [] [text "Elm-UI Kitchen Sink"]
        , Ui.text "An opinionated UI library for the web in Elm, following
                   the Elm Architecture."
        , node "p" []
          [ Ui.IconButton.primaryBig
              "Get Started at Github" "social-github" "right"
              address (Open "https://github.com/gdotdesign/elm-ui") ]
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
                ([ Ui.Button.primaryBig "Primary" address Alert
                 , Ui.Button.secondary "Secondary" address Nothing
                 , Ui.Button.success "Success" address Nothing
                 , Ui.Button.warning "Warning" address Nothing
                 , Ui.Button.dangerSmall "Danger" address Nothing
                 ] ++ clicked)
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
                [ Ui.IconButton.primaryBig
                    "Load" "android-download" "right" address Nothing
                , Ui.IconButton.primary
                    "" "archive" "right" address Nothing
                , Ui.IconButton.secondary
                    "Send" "arrow-left-c" "left" address Nothing
                , Ui.IconButton.success
                    "Success" "checkmark" "right" address Nothing
                , Ui.IconButton.warning
                    "Warning" "alert" "right" address Nothing
                , Ui.IconButton.dangerSmall
                    "Danger" "close" "right" address Nothing
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
          , componentHeader "NotificationCenter"
          , tableRow ( Ui.IconButton.primary
                        "Show Notification"
                        "alert-circled"
                        "right"
                        address
                        ShowNotification)
                     (text "")
                     (text "")
          , componentHeader "Modal"
          , tableRow ( Ui.IconButton.primary
                        "Open Modal" "android-open" "right" address OpenModal)
                     (text "")
                     (text "")
          , componentHeader "Dropdown Menu"
          , tableRow ( Ui.DropdownMenu.view
                       (forwardTo address DropdownMenu)
                       (Ui.IconButton.secondary
                          "Open" "chevron-down" "right" address Nothing)
                       [ Ui.DropdownMenu.item
                          [ onClick address CloseMenu ]
                          [ Ui.icon "android-download" True []
                          , node "span" [] [text "Download"]
                          ]
                       , Ui.DropdownMenu.item
                          [ onClick address CloseMenu ]
                          [ Ui.icon "trash-b" True []
                          , node "span" [] [text "Delete"]
                          ]
                       ]
                       model.menu)
                     (text "")
                     (text "")
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
    DropdownMenu act ->
      { model | menu = Ui.DropdownMenu.update act model.menu                 }
    Slider act ->
      { model | slider = Ui.Slider.update act model.slider                   }
    Modal act ->
      { model | modal = Ui.Modal.update act model.modal                      }
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

    CloseMenu ->
      { model | menu = Ui.DropdownMenu.close model.menu }
    Open url ->
      Ui.open url model

    EscIsDown bool ->
      { model | menu = Ui.DropdownMenu.close model.menu
              , modal = Ui.Modal.close model.modal
      }

    CloseModal ->
      { model | modal = Ui.Modal.close model.modal }

    OpenModal ->
      { model | modal = Ui.Modal.open model.modal }

    Alert ->
      { model | clicked = True }

    _ ->
      model

update' : Action -> Model -> (Model, Effects.Effects Action)
update' action model =
  case action of
    Notis act ->
      let
        (notis, effect) = Ui.NotificationCenter.update act model.notifications
      in
        ({ model | notifications = notis }, Effects.map Notis effect)
    ShowNotification ->
      let
        (notis, effect) = Ui.NotificationCenter.notify (text "Test Notification") model.notifications
      in
        ({ model | notifications = notis }, Effects.map Notis effect)
    _ ->
      update action model
        |> fxNone

app =
  StartApp.start { init = (init, Effects.none)
                 , view = view
                 , update = update'
                 , inputs = [ Signal.map MousePosition Mouse.position
                            , Signal.map MouseIsDown Mouse.isDown
                            , Signal.map EscIsDown (Keyboard.isDown 27)
                            ]
                 }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
