import Signal exposing (forwardTo)
import Maybe.Extra
import Date.Format
import List.Extra
import Ext.Color
import Ext.Date
import StartApp
import Keyboard
import Effects
import Mouse
import Color
import Task
import Date
import Time
import Set

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
import Ui.Ratings
import Ui.Button
import Ui.Slider
import Ui.Pager
import Ui.Modal
import Ui.Image
import Ui.Input
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
  | Ratings Ui.Ratings.Action
  | Slider Ui.Slider.Action
  | Image Ui.Image.Action
  | Input Ui.Input.Action
  | Modal Ui.Modal.Action
  | Pager Ui.Pager.Action
  | App Ui.App.Action
  | MousePosition (Int, Int)
  | MouseIsDown Bool
  | ShowNotification
  | AppAction String
  | EscIsDown Bool
  | Open String
  | CloseMenu
  | CloseModal
  | OpenModal
  | Nothing
  | Alert
  | PreviousPage
  | NextPage
  | ChooserChanged (Set.Set String)
  | DatePickerChanged Time.Time
  | InplaceInputChanged String
  | CalendarChanged Time.Time
  | Checkbox2Changed Bool
  | Checkbox3Changed Bool
  | CheckboxChanged Bool
  | RatingsChanged Float
  | Scrolled Bool
  | Loaded Bool

type alias Model =
  { app : Ui.App.Model
  , mailbox : Signal.Mailbox Action
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
  , ratings : Ui.Ratings.Model
  , chooser : Ui.Chooser.Model
  , slider : Ui.Slider.Model
  , modal : Ui.Modal.Model
  , image : Ui.Image.Model
  , input : Ui.Input.Model
  , pager : Ui.Pager.Model
  , clicked : Bool
  }

init : Model
init =
  let
    datePickerOptions =
      Ui.DatePicker.init
        (forwardTo address DatePicker)
        (forwardTo address DatePickerChanged)
        (Ext.Date.now ())
    input = Ui.Input.init ""
    pager = Ui.Pager.init 0
    address = mailbox.address
    mailbox = Signal.mailbox Nothing
    colorMailbox = Signal.mailbox (Ext.Color.toHsv Color.yellow)
  in
    { calendar = Ui.Calendar.init
        (forwardTo address CalendarChanged)
        (Ext.Date.createDate 2015 5 1)
    , datePicker = { datePickerOptions | format = "%Y %B %e." }
    , pager = { pager | width = "100%", height = "200px" }
    , notifications = Ui.NotificationCenter.init 4000 320
    , input = { input | placeholder = "Type here..." }
    , inplaceInput = Ui.InplaceInput.init
        (forwardTo address InplaceInputChanged)
        "Test Value"
    , colorPicker = Ui.ColorPicker.init colorMailbox.address Color.yellow
    , colorPanel = Ui.ColorPanel.init colorMailbox.address Color.blue
    , numberRange = Ui.NumberRange.init 0
    , checkbox3 = Ui.Checkbox.init False (forwardTo address Checkbox3Changed)
    , checkbox2 = Ui.Checkbox.init False (forwardTo address Checkbox2Changed)
    , checkbox = Ui.Checkbox.init False (forwardTo address CheckboxChanged)
    , textarea = Ui.Textarea.init "Test"
    , numberPad = Ui.NumberPad.init 0
    , image = Ui.Image.init imageUrl
    , ratings = Ui.Ratings.init (forwardTo address RatingsChanged) 5 0.4
    , slider = Ui.Slider.init 50
    , menu = Ui.DropdownMenu.init
    , modal = Ui.Modal.init
    , mailbox = mailbox
    , clicked = False
    , chooser = Ui.Chooser.init
        (forwardTo address ChooserChanged)
        data
        "Select a country..." ""
    , app = Ui.App.init
        (forwardTo address Loaded)
        (forwardTo address Scrolled)
        "Elm-UI Kitchen Sink"
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
    , numberPad, ratings, pager, input } = model

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
          , componentHeader "Ratings"
          , tableRow (Ui.Ratings.view (forwardTo address Ratings) ratings)
                     (Ui.Ratings.view (forwardTo address Ratings)
                       { ratings | readonly = True })
                     (Ui.Ratings.view (forwardTo address Ratings)
                       { ratings | disabled = True })
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

          , componentHeader "Input"
          , tableRow (Ui.Input.view (forwardTo address Input)
                       input)
                     (Ui.Input.view (forwardTo address Input)
                       { input | readonly = True })
                     (Ui.Input.view (forwardTo address Input)
                       { input | disabled = True })

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

          , componentHeader "Pager"
          , tr []
            [ td [colspan 3]
              [ Ui.Pager.view (forwardTo address Pager)
                [ text "Page 1"
                , text "Page 2"
                , text "Page 3"
                ]
                pager
              ]
            ]
          , tr []
            [ td [colspan 3]
              [ Ui.Container.row []
                [ Ui.IconButton.primary "Previous Page" "chevron-left" "left" address PreviousPage
                , Ui.spacer
                , Ui.IconButton.primary "Next Page" "chevron-right" "right" address NextPage
                ]
              ]
            ]
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

update : Action -> Model -> Model
update action model =
  case action of
    DropdownMenu act ->
      { model | menu = Ui.DropdownMenu.update act model.menu }

    Modal act ->
      { model | modal = Ui.Modal.update act model.modal }

    Image act ->
      { model | image = Ui.Image.update act model.image }

    Pager act ->
      { model | pager = Ui.Pager.update act model.pager }

    MouseIsDown value ->
      { model
        | numberRange = Ui.NumberRange.handleClick value model.numberRange
        , colorPicker = Ui.ColorPicker.handleClick value model.colorPicker
        , colorPanel = Ui.ColorPanel.handleClick value model.colorPanel
        , menu = Ui.DropdownMenu.handleClick value model.menu
        , slider = Ui.Slider.handleClick value model.slider
        }

    Scrolled _ ->
      { model | menu = Ui.DropdownMenu.close model.menu }

    CloseMenu ->
      { model | menu = Ui.DropdownMenu.close model.menu }

    Open url ->
      Ui.open url model

    NextPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active + 1)) model.pager }

    PreviousPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active - 1)) model.pager }

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
    Input act ->
      let
        (input, effect) = Ui.Input.update act model.input
      in
        ({ model | input = input }, Effects.map Input effect)
    TextArea act ->
      let
        (textarea, effect) = Ui.Textarea.update act model.textarea
      in
        ({ model | textarea = textarea }, Effects.map TextArea effect)
    NumberPad act ->
      let
        (numberPad, effect) = Ui.NumberPad.update act model.numberPad
      in
        ({ model | numberPad = numberPad }, Effects.map NumberPad effect)
    InplaceInput act ->
      let
        (inplaceInput, effect) = Ui.InplaceInput.update act model.inplaceInput
      in
        ({ model | inplaceInput = inplaceInput }, Effects.map InplaceInput effect)
    Chooser act ->
      let
        (chooser, effect) = Ui.Chooser.update act model.chooser
      in
        ({ model | chooser = chooser }, Effects.map Chooser effect)
    Checkbox2 act ->
      let
        (checkbox2, effect) = Ui.Checkbox.update act model.checkbox2
      in
        ({ model | checkbox2 = checkbox2 }, Effects.map Checkbox2 effect)
    Checkbox3 act ->
      let
        (checkbox3, effect) = Ui.Checkbox.update act model.checkbox3
      in
        ({ model | checkbox3 = checkbox3 }, Effects.map Checkbox3 effect)
    Checkbox act ->
      let
        (checkbox, effect) = Ui.Checkbox.update act model.checkbox
      in
        ({ model | checkbox = checkbox }, Effects.map Checkbox effect)
    ColorPicker act ->
      let
        (colorPicker, effect) = Ui.ColorPicker.update act model.colorPicker
      in
        ({ model | colorPicker = colorPicker }, Effects.map ColorPicker effect)
    ColorPanel act ->
      let
        (colorPanel, effect) = Ui.ColorPanel.update act model.colorPanel
      in
        ({ model | colorPanel = colorPanel }, Effects.map ColorPanel effect)
    DatePicker act ->
      let
        (datePicker, effect) = Ui.DatePicker.update act model.datePicker
      in
        ({ model | datePicker = datePicker }, Effects.map DatePicker effect)
    Calendar act ->
      let
        (calendar, effect) = Ui.Calendar.update act model.calendar
      in
        ({ model | calendar = calendar}, Effects.map Calendar effect)
    Ratings act ->
      let
        (ratings, effect) = Ui.Ratings.update act model.ratings
      in
        ({ model | ratings = ratings }, Effects.map Ratings effect)
    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Effects.map App effect)
    Notis act ->
      let
        (notis, effect) = Ui.NotificationCenter.update act model.notifications
      in
        ({ model | notifications = notis }, Effects.map Notis effect)
    NumberRange act ->
      let
        (numberRange, effect) = Ui.NumberRange.update act model.numberRange
      in
        ({ model | numberRange = numberRange}, Effects.map NumberRange effect)
    Slider act ->
      let
        (slider, effect) = Ui.Slider.update act model.slider
      in
        ({ model | slider = slider }, Effects.map Slider effect)

    MousePosition (x,y) ->
      let
        (colorPicker, colorPickerEffect) =
          Ui.ColorPicker.handleMove x y model.colorPicker
        (colorPanel, colorPanelEffect) =
          Ui.ColorPanel.handleMove x y model.colorPanel
        (numberRange, numberRangeEffect) =
          Ui.NumberRange.handleMove x y model.numberRange
        (slider, sliderEffect) =
          Ui.Slider.handleMove x y model.slider
      in
        ({ model
          | numberRange = numberRange
          , colorPicker = colorPicker
          , colorPanel = colorPanel
          , slider = slider
          }, Effects.batch [ Effects.map ColorPanel colorPanelEffect
                           , Effects.map ColorPicker colorPickerEffect
                           , Effects.map NumberRange numberRangeEffect
                           , Effects.map Slider sliderEffect
                           ])

    InplaceInputChanged value ->
      notify ("Inplace input changed to: " ++ value) model
    CheckboxChanged value ->
      notify ("Checkbox changed to: " ++ (toString value)) model
    Checkbox2Changed value ->
      notify ("Toggle changed to: " ++ (toString value)) model
    Checkbox3Changed value ->
      notify ("Radio changed to: " ++ (toString value)) model
    ShowNotification ->
      notify "Test Notification" model
    ChooserChanged set ->
      let
        selected =
          Ui.Chooser.getFirstSelected model.chooser
          |> Maybe.map (\value -> List.Extra.find (\item -> item.value == value) data)
          |> Maybe.Extra.join
          |> Maybe.map .label
          |> Maybe.withDefault ""
      in
        notify ("Chooser changed to: " ++ selected) model
    CalendarChanged time ->
      notify ("Calendar changed to: " ++ (Date.Format.format "%Y-%m-%d" (Date.fromTime time))) model
    DatePickerChanged time ->
      notify ("Date picker changed to: " ++ (Date.Format.format "%Y-%m-%d" (Date.fromTime time))) model
    RatingsChanged value ->
      notify ("Ratings changed to: " ++ (toString (Ui.Ratings.valueAsStars value model.ratings))) model
    _ ->
      (update action model, Effects.none)

notify : String -> Model -> (Model, Effects.Effects Action)
notify message model =
  let
    (notis, effect) = Ui.NotificationCenter.notify (text message) model.notifications
  in
    ({ model | notifications = notis }, Effects.map Notis effect)

app =
  let
    initial =
      init

    inputs =
      -- Lifecycle
      [ Signal.map EscIsDown (Keyboard.isDown 27)
      , Signal.map MousePosition Mouse.position
      , Signal.map MouseIsDown Mouse.isDown
      -- Mailbox
      , initial.mailbox.signal
      ]
  in
    StartApp.start { init = (initial, Effects.none)
                   , view = view
                   , update = update'
                   , inputs = inputs
                   }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
