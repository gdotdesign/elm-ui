module Main exposing (..)

import Date.Extra.Config.Configs as DateConfigs
import Date.Extra.Format
import List.Extra
import Ext.Color
import Ext.Date
import Color
import Task
import Date
import Time
import Set
import Dom

import Html.Attributes exposing (style, classList, class, colspan, href)
import Html.Events exposing (onClick)
import Html exposing (div, text, node, table, tr, td)

import Ui.Native.FileManager as FileManager exposing (File)
import Ui.Native.LocalStorage as LocalStorage
import Ui.Native.Browser as Browser
import Ui.Native.Scrolls as Scrolls
import Ui.Native.Uid as Uid

import Ui.NotificationCenter
import Ui.DropdownMenu
import Ui.InplaceInput
import Ui.SearchInput
import Ui.NumberRange
import Ui.ButtonGroup
import Ui.ColorPicker
import Ui.DatePicker
import Ui.ColorPanel
import Ui.IconButton
import Ui.FileInput
import Ui.NumberPad
import Ui.Container
import Ui.Calendar
import Ui.Checkbox
import Ui.Textarea
import Ui.Chooser
import Ui.Ratings
import Ui.Button
import Ui.Tagger
import Ui.Layout
import Ui.Header
import Ui.Slider
import Ui.Loader
import Ui.Pager
import Ui.Modal
import Ui.Image
import Ui.Input
import Ui.Time
import Ui.Tabs
import Ui.App
import Ui
import Kitchensink.Showcase as Showcase


type Msg {- Showcase models -}
  = InplaceInput (Showcase.Msg Ui.InplaceInput.Msg)
  | NumberRange (Showcase.Msg Ui.NumberRange.Msg)
  | ColorPicker (Showcase.Msg Ui.ColorPicker.Msg)
  | SearchInput (Showcase.Msg Ui.SearchInput.Msg)
  | DatePicker (Showcase.Msg Ui.DatePicker.Msg)
  | ColorPanel (Showcase.Msg Ui.ColorPanel.Msg)
  | NumberPad (Showcase.Msg Ui.NumberPad.Msg)
  | Checkbox2 (Showcase.Msg Ui.Checkbox.Msg)
  | Checkbox3 (Showcase.Msg Ui.Checkbox.Msg)
  | TextArea (Showcase.Msg Ui.Textarea.Msg)
  | Calendar (Showcase.Msg Ui.Calendar.Msg)
  | Checkbox (Showcase.Msg Ui.Checkbox.Msg)
  | FileInput (Showcase.Msg Ui.FileInput.Msg)
  | Chooser (Showcase.Msg Ui.Chooser.Msg)
  | Ratings (Showcase.Msg Ui.Ratings.Msg)
  | Slider (Showcase.Msg Ui.Slider.Msg)
  | Tagger (Showcase.Msg Ui.Tagger.Msg)
  | Input (Showcase.Msg Ui.Input.Msg)
  | Tabs (Showcase.Msg Ui.Tabs.Msg) {- Components -}
  | DropdownMenu Ui.DropdownMenu.Msg
  | Notis Ui.NotificationCenter.Msg
  | Image Ui.Image.Msg
  | Modal Ui.Modal.Msg
  | Pager Ui.Pager.Msg
  | Time2 Ui.Time.Msg
  | Time Ui.Time.Msg
  | App Ui.App.Msg {- Notify about changes -}
  | ColorPickerChanged Ext.Color.Hsv
  | ColorPanelChanged Ext.Color.Hsv
  | ChooserChanged (Set.Set String)
  | DatePickerChanged Time.Time
  | InplaceInputChanged String
  | CalendarChanged Time.Time
  | SearchInputChanged String
  | BreadcrumbClicked String
  | NumberRangeChanged Float
  | TextAreaChanged String
  | Checkbox2Changed Bool
  | Checkbox3Changed Bool
  | CheckboxChanged Bool
  | RatingsChanged Float
  | ButtonClicked String {- Kitchensink related. -}
  | FileChanged File
  | ShowNotification
  | EscIsDown Bool
  | FocusChooser
  | Open String
  | CloseMenu
  | Alert
  | NotFound Dom.Error
  | WindowOpen (Result String ())
  | Focused (Result Dom.Error ())
  | SetTitle
  | NoOp2 ()
  | NoOp {- Component related. -}
  | TaggerRemove String
  | TaggerAdd String
  | PreviousPage
  | NextPage
  | CloseModal
  | OpenModal {- Storage related -}
  | TextareaLoaded (Result String String)
  | TextareaSaved (Result String String)

type alias Model =
  {- Cache -}
  { tabsContents : List ( String, Html.Html Msg )
  , disabledIconButton : List (Html.Html Msg)
  , disabledButton : List (Html.Html Msg)
  , pagerContents : List (Html.Html Msg)
  , notificationButton : Html.Html Msg
  , modalView : Ui.Modal.ViewModel Msg
  , iconButtons : List (Html.Html Msg)
  , taggerData : List Ui.Tagger.Tag
  , buttons : List (Html.Html Msg)
  , pagerControls : Html.Html Msg
  , modalButton : Html.Html Msg
  , infos : List (Html.Html Msg)
  , clicked : Bool
  , dropdownMenu :
      { element : Html.Html Msg
      , items : List (Html.Html Msg)
      }
  , buttonGroup :
      { enabled : Ui.ButtonGroup.Model Msg
      , disabled : Ui.ButtonGroup.Model Msg
      }
      {- Components -}
  , searchInput : Showcase.Model Ui.SearchInput.Model Ui.SearchInput.Msg Msg
  , inplaceInput : Showcase.Model Ui.InplaceInput.Model Ui.InplaceInput.Msg Msg
  , colorPicker : Showcase.Model Ui.ColorPicker.Model Ui.ColorPicker.Msg Msg
  , numberRange : Showcase.Model Ui.NumberRange.Model Ui.NumberRange.Msg Msg
  , colorPanel : Showcase.Model Ui.ColorPanel.Model Ui.ColorPanel.Msg Msg
  , datePicker : Showcase.Model Ui.DatePicker.Model Ui.DatePicker.Msg Msg
  , numberPad : Showcase.Model Ui.NumberPad.Model Ui.NumberPad.Msg Msg
  , fileInput : Showcase.Model Ui.FileInput.Model Ui.FileInput.Msg Msg
  , checkbox3 : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Msg Msg
  , checkbox2 : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Msg Msg
  , checkbox : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Msg Msg
  , textarea : Showcase.Model Ui.Textarea.Model Ui.Textarea.Msg Msg
  , calendar : Showcase.Model Ui.Calendar.Model Ui.Calendar.Msg Msg
  , ratings : Showcase.Model Ui.Ratings.Model Ui.Ratings.Msg Msg
  , chooser : Showcase.Model Ui.Chooser.Model Ui.Chooser.Msg Msg
  , slider : Showcase.Model Ui.Slider.Model Ui.Slider.Msg Msg
  , tagger : Showcase.Model Ui.Tagger.Model Ui.Tagger.Msg Msg
  , input : Showcase.Model Ui.Input.Model Ui.Input.Msg Msg
  , tabs : Showcase.Model Ui.Tabs.Model Ui.Tabs.Msg Msg
  , notifications : Ui.NotificationCenter.Model Msg
  , app : Ui.App.Model
  , menu : Ui.DropdownMenu.Model
  , loader : Ui.Loader.Model
  , modal : Ui.Modal.Model
  , image : Ui.Image.Model
  , pager : Ui.Pager.Model
  , time2 : Ui.Time.Model
  , time : Ui.Time.Model
  }


init : Model
init =
  let
    pager =
      Ui.Pager.init 0

    loader =
      Ui.Loader.init 0

    buttonGroup =
      Ui.ButtonGroup.init
        [ ( "A", (ButtonClicked "A") )
        , ( "B", (ButtonClicked "B") )
        , ( "C", (ButtonClicked "C") )
        , ( "D", (ButtonClicked "D") )
        ]
  in
    { calendar =
        Showcase.init
          (\_ -> Ui.Calendar.init (Ext.Date.createDate 2015 5 1))
          Ui.Calendar.update
          (Ui.Calendar.subscribe CalendarChanged)
          (\_ -> Sub.none)
    , tabs =
        Showcase.init
          (\_ -> Ui.Tabs.init 0)
          Ui.Tabs.update
          (\_ -> Sub.none)
          (\_ -> Sub.none)
    , tabsContents =
        [ ( "First", text "First Tab" )
        , ( "Second", text "Second Tab" )
        , ( "Third", text "Third Tab" )
        ]
    , tagger =
        Showcase.init
          (\_ -> Ui.Tagger.init "Add a tag...")
          Ui.Tagger.update
          (Ui.Tagger.subscribe TaggerAdd TaggerRemove)
          (\_ -> Sub.none)
    , searchInput =
        Showcase.init
          (\_ -> Ui.SearchInput.init 1000 "Search")
          Ui.SearchInput.update
          (Ui.SearchInput.subscribe SearchInputChanged)
          (\_ -> Sub.none)
    , notificationButton =
        Ui.IconButton.primary
          "Show Notification"
          "alert-circled"
          "right"
          ShowNotification
    , pagerContents =
        [ text "Page 1"
        , text "Page 2"
        , text "Page 3"
        ]
    , pagerControls =
        Ui.Container.row
          []
          [ Ui.IconButton.primary "Previous Page" "chevron-left" "left" PreviousPage
          , Ui.spacer
          , Ui.IconButton.primary "Next Page" "chevron-right" "right" NextPage
          ]
    , dropdownMenu =
        { element =
            Ui.IconButton.secondary
              "Open"
              "chevron-down"
              "right"
              NoOp
        , items =
            [ Ui.DropdownMenu.item
                [ onClick CloseMenu ]
                [ Ui.icon "android-download" True []
                , node "span" [] [ text "Download" ]
                ]
            , Ui.DropdownMenu.item
                [ onClick CloseMenu ]
                [ Ui.icon "trash-b" True []
                , node "span" [] [ text "Delete" ]
                ]
            ]
        }
    , infos =
        [ Ui.subTitle [] [ text "Components" ]
        , Ui.textBlock "The business logic for following components are\n                      implemented fully in Elm, with minimal Native\n                      bindings, following the Elm Architecture. Most\n                      components implement disabled and readonly states."
        ]
    , modalButton =
        Ui.IconButton.primary
          "Open Modal"
          "android-open"
          "right"
          OpenModal
    , modalView =
        { title = "Test Modal"
        , content =
            [ node "p" [] [ text "This is a modal window." ]
            , node "p" [] [ text "Lorem ipsum dolor sit amet, consectetur\n                                         adipiscing elit. Pellentesque ornare odio sed\n                                         lorem malesuada, id efficitur elit consequat.\n                                         Aenean suscipit, est a varius aliquam,\n                                         turpis diam sollicitudin tortor, in venenatis\n                                         felis nisl ac ex. Quisque finibus nisl nec urna\n                                         laoreet aliquet. Maecenas et volutpat arcu, a\n                                         dapibus tellus. Praesent nec enim velit. Class\n                                         aptent taciti sociosqu ad litora torquent per\n                                         conubia nostra, per inceptos himenaeos. Nullam\n                                         volutpat turpis vel lorem fringilla, pulvinar\n                                         viverra dolor varius." ]
            ]
        , footer =
            [ Ui.Container.rowEnd
                []
                [ Ui.Button.primary "Close" CloseModal ]
            ]
        }
    , buttons =
        [ Ui.Button.primaryBig "Primary" Alert
        , Ui.Button.secondary "Secondary" FocusChooser
        , Ui.Button.success "Success" SetTitle
        , Ui.Button.warning "Warning" (Open "http://www.google.com")
        , Ui.Button.dangerSmall "Danger" NoOp
        ]
    , disabledIconButton =
        [ Ui.IconButton.view
            NoOp
            { side = "left"
            , text = "Disabled"
            , kind = "success"
            , glyph = "paper-airplane"
            , size = "medium"
            , disabled = True
            , readonly = False
            }
        ]
    , disabledButton =
        [ Ui.Button.view
            NoOp
            { text = "Disabled"
            , kind = "danger"
            , size = "medium"
            , disabled = True
            , readonly = False
            }
        ]
    , iconButtons =
        [ Ui.IconButton.primaryBig
            "Load"
            "android-download"
            "right"
            NoOp
        , Ui.IconButton.primary
            ""
            "archive"
            "right"
            NoOp
        , Ui.IconButton.secondary
            "Send"
            "arrow-left-c"
            "left"
            NoOp
        , Ui.IconButton.success
            "Success"
            "checkmark"
            "right"
            NoOp
        , Ui.IconButton.warning
            "Warning"
            "alert"
            "right"
            NoOp
        , Ui.IconButton.dangerSmall
            "Danger"
            "close"
            "right"
            NoOp
        ]
    , taggerData =
        [ { label = "Pear", id = "2" }
        , { label = "Apple", id = "1" }
        , { label = "Orange", id = "0" }
        ]
    , datePicker =
        Showcase.init
          (\_ -> Ui.DatePicker.init (Ext.Date.now ()))
          Ui.DatePicker.update
          (\_ -> Sub.none)
          (\_ -> Sub.none)
    , pager = { pager | width = "100%", height = "200px" }
    , notifications = Ui.NotificationCenter.init 4000 400
    , fileInput =
        Showcase.init
          (\_ -> Ui.FileInput.init "image/*")
          Ui.FileInput.update
          (Ui.FileInput.subscribe FileChanged)
          (\_ -> Sub.none)
    , input =
        Showcase.init
          (\_ ->
            Ui.Input.init "" "Type here..."
              |> Ui.Input.showClearIcon True
          )
          Ui.Input.update
          (\_ -> Sub.none)
          (\_ -> Sub.none)
    , inplaceInput =
        Showcase.init
          (\_ -> Ui.InplaceInput.init "Test" "Placeholder")
          Ui.InplaceInput.update
          (\_ -> Sub.none)
          (\_ -> Sub.none)
    , colorPicker =
        Showcase.init
          (\_ -> Ui.ColorPicker.init Color.yellow)
          Ui.ColorPicker.update
          (\_ -> Sub.none)
          (\model -> Ui.ColorPicker.subscriptions model)
    , colorPanel =
        Showcase.init
          (\_ -> Ui.ColorPanel.init Color.blue)
          Ui.ColorPanel.update
          (\_ -> Sub.none)
          (\model -> Ui.ColorPanel.subscriptions model)
    , numberRange =
        Showcase.init
          (\_ -> Ui.NumberRange.init 0)
          Ui.NumberRange.update
          (\_ -> Sub.none)
          (\model -> Ui.NumberRange.subscriptions model)
    , buttonGroup =
        { enabled = buttonGroup
        , disabled = { buttonGroup | disabled = True }
        }
    , checkbox3 =
        Showcase.init
          (\_ -> Ui.Checkbox.init False)
          Ui.Checkbox.update
          (Ui.Checkbox.subscribe Checkbox3Changed)
          (\_ -> Sub.none)
    , checkbox2 =
        Showcase.init
          (\_ -> Ui.Checkbox.init False)
          Ui.Checkbox.update
          (Ui.Checkbox.subscribe Checkbox2Changed)
          (\_ -> Sub.none)
    , checkbox =
        Showcase.init
          (\_ -> Ui.Checkbox.init False)
          Ui.Checkbox.update
          (Ui.Checkbox.subscribe CheckboxChanged)
          (\_ -> Sub.none)
    , textarea =
        Showcase.init
          (\_ -> Ui.Textarea.init "Test" "Placeholder")
          Ui.Textarea.update
          (Ui.Textarea.subscribe TextAreaChanged)
          (\_ -> Sub.none)
    , numberPad =
        Showcase.init
          (\_ -> Ui.NumberPad.init 0)
          Ui.NumberPad.update
          (\_ -> Sub.none)
          (\_ -> Sub.none)
    , image = Ui.Image.init imageUrl
    , ratings =
        Showcase.init
          (\_ -> Ui.Ratings.init 5 0.4)
          Ui.Ratings.update
          (Ui.Ratings.subscribe RatingsChanged)
          (\_ -> Sub.none)
    , slider =
        Showcase.init
          (\_ -> Ui.Slider.init 50)
          Ui.Slider.update
          (\_ -> Sub.none)
          (\model -> Ui.Slider.subscriptions model)
    , menu = Ui.DropdownMenu.init
    , modal = Ui.Modal.init
    , loader = { loader | shown = True }
    , time = Ui.Time.init (Ext.Date.createDate 2015 11 1)
    , time2 = Ui.Time.init (Ext.Date.now ())
    , clicked = False
    , chooser =
        Showcase.init
          (\_ -> Ui.Chooser.init data "Select a country..." "")
          Ui.Chooser.update
          (Ui.Chooser.subscribe ChooserChanged)
          (\_ -> Sub.none)
    , app = Ui.App.init
    }


data : List Ui.Chooser.Item
data =
  [ { label = "Hungary", value = "0" }
  , { label = "Germany", value = "1" }
  , { label = "French", value = "2" }
  , { label = "Italy", value = "3" }
  , { label = "Russia", value = "4" }
  , { label = "United States", value = "6" }
  , { label = "United Kingdom", value = "7" }
  , { label = "Some very long named country", value = "5" }
  ]


imageUrl : String
imageUrl =
  "http://rs1371.pbsrc.com/albums/ag299/Victor_Binhara/Despicable%20Me/DespicableMe2_zpsc67ebdc5.jpg~c200"


componentHeader : String -> Html.Html Msg
componentHeader title =
  componentHeaderRender title


componentHeaderRender : String -> Html.Html Msg
componentHeaderRender title =
  tr [] [ td [ colspan 3 ] [ text title ] ]


tableRow : Html.Html Msg -> Html.Html Msg -> Html.Html Msg -> Html.Html Msg
tableRow active readonly disabled =
  tr
    []
    [ td [] [ active ]
    , td [] [ readonly ]
    , td [] [ disabled ]
    ]


view : Model -> Html.Html Msg
view model =
  let
    emptyText =
      text ""

    { chooser, colorPanel, datePicker, colorPicker, numberRange, slider,
      checkbox, checkbox2, checkbox3, calendar, inplaceInput, textarea,
      numberPad, ratings, pager, input, buttonGroup, buttons, iconButtons,
      disabledButton, disabledIconButton, modalView, infos, modalButton,
      dropdownMenu, pagerControls, notificationButton, tagger, pagerContents,
      searchInput, tabs, tabsContents, taggerData, fileInput } =
      model

    clicked =
      if model.clicked then
        [ node "clicked" [] [ emptyText ] ]
      else
        []
  in
    Ui.App.view
      App
      model.app
      [ Ui.NotificationCenter.view Notis model.notifications
      , Ui.Modal.view Modal modalView model.modal
      , Ui.Layout.website
          [ Ui.Header.view
            [ Ui.Header.icon
              { glyph = "grid"
              , action = Just NoOp
              , target = ""
              , link = Nothing
              , size = 32
              }
            , Ui.Header.title
              { text = "Elm-UI Kitchen Sink"
              , target = ""
              , action = Nothing
              , link = Nothing
              }
            , Ui.spacer
            , Ui.Header.iconItem
              { text = "Github"
              , action = Nothing
              , link = Just "https://github.com/gdotdesign/elm-ui"
              , glyph = "social-github"
              , target = "_blank"
              , side = "right"
              }
            , Ui.Header.separator
            , Ui.Header.iconItem
              { text = "Guide"
              , action = Nothing
              , glyph = "bookmark"
              , link = Just "https://gdotdesign.gitbooks.io/elm-ui-guide/content/"
              , target = "_blank"
              , side = "right"
              }
            , Ui.Header.separator
            , Ui.Header.iconItem
              { text = "Examples"
              , action = Nothing
              , link = Just "https://github.com/gdotdesign/elm-ui-examples"
              , target = "_blank"
              , glyph = "clipboard"
              , side = "right"
              }
            ]
          ]
          [ node
              "kitchen-sink"
              []
              (infos
                ++ [ table
                      []
                      [ tr
                          []
                          [ td [] [ text "Active" ]
                          , td [] [ text "Readonly" ]
                          , td [] [ text "Disabled" ]
                          ]
                      , componentHeader "Button"
                      , tr
                          []
                          [ td
                              [ colspan 2 ]
                              [ Ui.Container.row [] (buttons ++ clicked) ]
                          , td [] disabledButton
                          ]
                      , componentHeader "Icon Button"
                      , tr
                          []
                          [ td
                              [ colspan 2 ]
                              [ Ui.Container.row [] iconButtons
                              ]
                          , td [] disabledIconButton
                          ]
                      , componentHeader "Button Group"
                      , tableRow
                          (Ui.ButtonGroup.view buttonGroup.enabled)
                          (emptyText)
                          (Ui.ButtonGroup.view buttonGroup.disabled)
                      , componentHeader "Ratings"
                      , Showcase.view Ratings Ui.Ratings.view ratings
                      , componentHeader "NotificationCenter"
                      , tableRow
                          (notificationButton)
                          (emptyText)
                          (emptyText)
                      , componentHeader "Modal"
                      , tableRow
                          (modalButton)
                          (emptyText)
                          (emptyText)
                      , componentHeader "Dropdown Menu"
                      , tableRow
                          (Ui.DropdownMenu.view
                            dropdownMenu
                            DropdownMenu
                            model.menu
                          )
                          (emptyText)
                          (emptyText)
                      , componentHeader "Calendar"
                      , Showcase.view Calendar (Ui.Calendar.view "en_us") calendar
                      , componentHeader "Tabs"
                      , Showcase.view2 Tabs (Ui.Tabs.view tabsContents) tabs
                      , componentHeader "Checkbox"
                      , Showcase.view Checkbox Ui.Checkbox.view checkbox
                      , Showcase.view Checkbox2 Ui.Checkbox.viewToggle checkbox2
                      , Showcase.view Checkbox3 Ui.Checkbox.viewRadio checkbox3
                      , componentHeader "Chooser"
                      , Showcase.view Chooser Ui.Chooser.view chooser
                      , componentHeader "Color Panel"
                      , Showcase.view ColorPanel Ui.ColorPanel.view colorPanel
                      , componentHeader "Color Picker"
                      , Showcase.view ColorPicker Ui.ColorPicker.view colorPicker
                      , componentHeader "Date Picker"
                      , Showcase.view DatePicker (Ui.DatePicker.view "en_us") datePicker
                      , componentHeader "Number Range"
                      , Showcase.view NumberRange Ui.NumberRange.view numberRange
                      , componentHeader "Slider"
                      , Showcase.view Slider Ui.Slider.view slider
                      , componentHeader "Tagger"
                      , Showcase.view Tagger (Ui.Tagger.view taggerData) tagger
                      , componentHeader "Time"
                      , tableRow
                          (Ui.Time.view model.time)
                          (Ui.Time.view model.time2)
                          emptyText
                      , componentHeader "Loader"
                      , tableRow
                          (Ui.Loader.barView model.loader)
                          (div
                            [ class "loader-container" ]
                            [ Ui.Loader.overlayView model.loader ]
                          )
                          emptyText
                      , componentHeader "Input"
                      , Showcase.view Input Ui.Input.view input
                      , componentHeader "Search Input"
                      , Showcase.view SearchInput Ui.SearchInput.view searchInput
                      , componentHeader "Autogrow Textarea"
                      , Showcase.view TextArea Ui.Textarea.view textarea
                      , componentHeader "Inplace Input"
                      , Showcase.view InplaceInput Ui.InplaceInput.view inplaceInput
                      , componentHeader "Number Pad"
                      , Showcase.view2 NumberPad (Ui.NumberPad.view { bottomLeft = text "", bottomRight = text "" }) numberPad
                      , componentHeader "FileInput"
                      , Showcase.view FileInput Ui.FileInput.view fileInput
                      , Showcase.view FileInput Ui.FileInput.viewDetails fileInput
                      , componentHeader "Pager"
                      , tr
                          []
                          [ td
                              [ colspan 3 ]
                              [ Ui.Pager.view Pager pagerContents pager
                              ]
                          ]
                      , tr
                          []
                          [ td
                              [ colspan 3 ]
                              [ pagerControls ]
                          ]
                      , componentHeader "Breadcrumbs"
                      , tr
                          []
                          [ td
                              [ colspan 3 ]
                              [ Ui.breadcrumbs
                                  (node "span" [] [ text "/" ])
                                  [ ( "First", Just (BreadcrumbClicked "First") )
                                  , ( "Second", Just (BreadcrumbClicked "Second") )
                                  , ( "Third", Nothing )
                                  ]
                              ]
                          ]
                      , componentHeader "Image"
                      , tr
                          []
                          [ td
                              []
                              [ Html.map Image (Ui.Image.view model.image) ]
                          , td [] []
                          , td [] []
                          ]
                      ]
                   ]
              )
          ]
          []
      ]


update : Msg -> Model -> Model
update msg model =
  case msg of
    DropdownMenu act ->
      { model | menu = Ui.DropdownMenu.update act model.menu }

    Modal act ->
      { model | modal = Ui.Modal.update act model.modal }

    Image act ->
      { model | image = Ui.Image.update act model.image }

    Pager act ->
      { model | pager = Ui.Pager.update act model.pager }

    CloseMenu ->
      { model | menu = Ui.DropdownMenu.close model.menu }

    NextPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active + 1)) model.pager }

    PreviousPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active - 1)) model.pager }

    EscIsDown bool ->
      { model
        | menu = Ui.DropdownMenu.close model.menu
        , modal = Ui.Modal.close model.modal
      }

    CloseModal ->
      { model | modal = Ui.Modal.close model.modal }

    OpenModal ->
      { model | modal = Ui.Modal.open model.modal }

    Alert ->
      { model | clicked = True }

    TextareaLoaded result ->
      case result of
        Ok value ->
          { model | textarea = Showcase.updateModels (\txta -> Ui.Textarea.setValue value txta) model.textarea }
        Err _ ->
          model

    TaggerRemove id ->
      { model | taggerData = List.filter (\item -> item.id /= id) model.taggerData }

    TaggerAdd value ->
      let
        tag =
          { label = value, id = Uid.uid () }
      in
        { model
          | taggerData = tag :: model.taggerData
          , tagger = Showcase.updateModels (Ui.Tagger.setValue "") model.tagger
        }

    _ ->
      model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
  case msg of
    TextAreaChanged value ->
      ( model, Task.attempt TextareaSaved (LocalStorage.setItem "textarea" value) )

    Time act ->
      let
        ( time, effect ) =
          Ui.Time.update act model.time
      in
        ( { model | time = time }, Cmd.map Time effect )

    Time2 act ->
      let
        ( time2, effect ) =
          Ui.Time.update act model.time2
      in
        ( { model | time2 = time2 }, Cmd.map Time effect )

    Tabs act ->
      let
        ( tabs, effect ) =
          Showcase.update act model.tabs
      in
        ( { model | tabs = tabs }, Cmd.map Tabs effect )

    Tagger act ->
      let
        ( tagger, effect ) =
          Showcase.update act model.tagger
      in
        ( { model | tagger = tagger }, Cmd.map Tagger effect )

    SearchInput act ->
      let
        ( searchInput, effect ) =
          Showcase.update act model.searchInput
      in
        ( { model | searchInput = searchInput }, Cmd.map SearchInput effect )

    Input act ->
      let
        ( input, effect ) =
          Showcase.update act model.input
      in
        ( { model | input = input }, Cmd.map Input effect )

    TextArea act ->
      let
        ( textarea, effect ) =
          Showcase.update act model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map TextArea effect )

    NumberPad act ->
      let
        ( numberPad, effect ) =
          Showcase.update act model.numberPad
      in
        ( { model | numberPad = numberPad }, Cmd.map NumberPad effect )

    InplaceInput act ->
      let
        ( inplaceInput, effect ) =
          Showcase.update act model.inplaceInput
      in
        ( { model | inplaceInput = inplaceInput }, Cmd.map InplaceInput effect )

    Chooser act ->
      let
        ( chooser, effect ) =
          Showcase.update act model.chooser
      in
        ( { model | chooser = chooser }, Cmd.map Chooser effect )

    Checkbox2 act ->
      let
        ( checkbox2, effect ) =
          Showcase.update act model.checkbox2
      in
        ( { model | checkbox2 = checkbox2 }, Cmd.map Checkbox2 effect )

    Checkbox3 act ->
      let
        ( checkbox3, effect ) =
          Showcase.update act model.checkbox3
      in
        ( { model | checkbox3 = checkbox3 }, Cmd.map Checkbox3 effect )

    Checkbox act ->
      let
        ( checkbox, effect ) =
          Showcase.update act model.checkbox
      in
        ( { model | checkbox = checkbox }, Cmd.map Checkbox effect )

    ColorPicker act ->
      let
        ( colorPicker, effect ) =
          Showcase.update act model.colorPicker
      in
        ( { model | colorPicker = colorPicker }, Cmd.map ColorPicker effect )

    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Showcase.update act model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel effect )

    DatePicker act ->
      let
        ( datePicker, effect ) =
          Showcase.update act model.datePicker
      in
        ( { model | datePicker = datePicker }, Cmd.map DatePicker effect )

    FileInput act ->
      let
        ( fileInput, effect ) =
          Showcase.update act model.fileInput
      in
        ( { model | fileInput = fileInput }, Cmd.map FileInput effect )

    Calendar act ->
      let
        ( calendar, effect ) =
          Showcase.update act model.calendar
      in
        ( { model | calendar = calendar }, Cmd.map Calendar effect )

    Ratings act ->
      let
        ( ratings, effect ) =
          Showcase.update act model.ratings
      in
        ( { model | ratings = ratings }, Cmd.map Ratings effect )

    App act ->
      let
        ( app, effect ) =
          Ui.App.update act model.app
      in
        ( { model | app = app }, Cmd.map App effect )

    Notis act ->
      let
        ( notis, effect ) =
          Ui.NotificationCenter.update act model.notifications
      in
        ( { model | notifications = notis }, Cmd.map Notis effect )

    NumberRange act ->
      let
        ( numberRange, effect ) =
          Showcase.update act model.numberRange
      in
        ( { model | numberRange = numberRange }, Cmd.map NumberRange effect )

    Slider act ->
      let
        ( slider, effect ) =
          Showcase.update act model.slider
      in
        ( { model | slider = slider }, Cmd.map Slider effect )

    ButtonClicked value ->
      notify ("Button clicked: " ++ value) model

    BreadcrumbClicked value ->
      notify ("Breadcrumb clicked:" ++ value) model

    InplaceInputChanged value ->
      notify ("Inplace input changed to: " ++ value) model

    CheckboxChanged value ->
      notify ("Checkbox changed to: " ++ (toString value)) model

    Checkbox2Changed value ->
      notify ("Toggle changed to: " ++ (toString value)) model

    Checkbox3Changed value ->
      notify ("Radio changed to: " ++ (toString value)) model

    SearchInputChanged value ->
      notify ("Search input changed to: " ++ (toString value)) model

    ColorPickerChanged value ->
      notify ("Color picker changed to: " ++ (Ext.Color.toCSSRgba value)) model

    NumberRangeChanged value ->
      notify ("Number range changed to: " ++ (toString value)) model

    ColorPanelChanged value ->
      notify ("Color panel changed to: " ++ (Ext.Color.toCSSRgba value)) model

    FileChanged value ->
      notify ("File input changed to: " ++ (value.name)) model

    ShowNotification ->
      notify "Test Notification" model

    ChooserChanged set ->
      let
        selected =
          Ui.Chooser.getFirstSelected model.chooser.enabled
            |> Maybe.map (\value -> List.Extra.find (\item -> item.value == value) data)
            |> joinMaybe
            |> Maybe.map .label
            |> Maybe.withDefault ""
      in
        notify ("Chooser changed to: " ++ selected) model

    CalendarChanged time ->
      notify ("Calendar changed to: " ++ (Date.Extra.Format.format (DateConfigs.getConfig "en") "%Y-%m-%d" (Date.fromTime time))) model

    DatePickerChanged time ->
      notify ("Date picker changed to: " ++ (Date.Extra.Format.format (DateConfigs.getConfig "en") "%Y-%m-%d" (Date.fromTime time))) model

    RatingsChanged value ->
      notify ("Ratings changed to: " ++ (toString (Ui.Ratings.valueAsStars value model.ratings.enabled))) model

    FocusChooser ->
      ( model, Task.attempt Focused (Dom.focus model.chooser.enabled.uid) )

    SetTitle ->
      ( model, Task.perform NoOp2 (Browser.setTitle "test"))

    Open url ->
      ( model, Task.attempt WindowOpen (Browser.openWindow url))

    WindowOpen result ->
      case result of
        Ok _ ->
          ( model, Cmd.none )
        Err error ->
          notify "Could not open window!" model

    _ ->
      ( update msg model, Cmd.none )


joinMaybe : Maybe (Maybe a) -> Maybe a
joinMaybe mx =
  case mx of
    Just x ->
      x

    Nothing ->
      Nothing


notify : String -> Model -> ( Model, Cmd Msg )
notify message model =
  let
    ( notis, effect ) =
      Ui.NotificationCenter.notify (text message) model.notifications
  in
    ( { model | notifications = notis }, Cmd.map Notis effect )


gatherSubs model =
  Sub.batch
    [ Showcase.subscribe model.ratings
    , Showcase.subscribe model.calendar
    , Showcase.subscribe model.checkbox
    , Showcase.subscribe model.checkbox2
    , Showcase.subscribe model.checkbox3
    , Showcase.subscribe model.searchInput
    , Showcase.subscribe model.textarea
    , Showcase.subscribe model.chooser
    , Showcase.subscribe model.tagger
    , Showcase.subscribe model.fileInput
    , Scrolls.scrolls CloseMenu
    , Sub.map App Ui.App.subscriptions
    , Sub.map Time Ui.Time.subscriptions
    , Sub.map Time2 Ui.Time.subscriptions
    , Sub.map ColorPanel (Showcase.subscriptions model.colorPanel)
    , Sub.map NumberRange (Showcase.subscriptions model.numberRange)
    , Sub.map Slider (Showcase.subscriptions model.slider)
    , Sub.map ColorPicker (Showcase.subscriptions model.colorPicker)
    , Sub.map DropdownMenu (Ui.DropdownMenu.subscriptions model.menu)
    ]


main =
  Html.program
    { init = ( init, Task.attempt TextareaLoaded (LocalStorage.getItem "textarea") )
    , view = view
    , update = update_
    , subscriptions = \model -> gatherSubs model
    }
