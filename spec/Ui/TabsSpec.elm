import Spec exposing (..)

import Html exposing (text)
import Steps exposing (..)
import Ui.Container
import Ui.Tabs


type alias Model =
  { tabs : Ui.Tabs.Model }


type Msg
  = Tabs Ui.Tabs.Msg


init : () -> Model
init _ =
  { tabs = Ui.Tabs.init () }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Tabs msg ->
      let
        ( tabs, cmd ) = Ui.Tabs.update msg model.tabs
      in
        ( { model | tabs = tabs }, Cmd.map Tabs cmd )


viewModel : Ui.Tabs.ViewModel Msg
viewModel =
  { contents =
    [ ("Tab 1", text "tab 1")
    , ("Tab 2", text "tab 2")
    , ("Tab 3", text "tab 3")
    ]
  , address = Tabs
  }


view : Model -> Html.Html Msg
view { tabs } =
  Ui.Container.row []
    [ Ui.Tabs.view viewModel tabs
    , Ui.Tabs.view viewModel { tabs | disabled = True }
    , Ui.Tabs.view viewModel { tabs | readonly = True }
    ]


specs : Node
specs =
  describe "Ui.Tabs"
    [ it "displays tabs"
      [ assert.elementPresent "ui-tabs-handle:nth-child(3)" ]

    , context "Tabs"
      [ it "have tabindex"
        [ assert.elementPresent "ui-tabs-handle:nth-child(1)[tabindex]"
        , assert.elementPresent "ui-tabs-handle:nth-child(2)[tabindex]"
        , assert.elementPresent "ui-tabs-handle:nth-child(3)[tabindex]"
        ]
      ]

    , context "Swicthing tabs"
      [ before
        [ assert.elementPresent "ui-tabs-handle:first-child[selected]"
        , assert.containsText
          { selector = "ui-tabs-content"
          , text = "tab 1"
          }
        ]
      , after
        [ assert.elementPresent "ui-tabs-handle:nth-child(2)[selected]"
        , assert.containsText
          { selector = "ui-tabs-content"
          , text = "tab 2"
          }
        ]
      , it "selects on click"
        [ steps.click "ui-tabs-handle:nth-child(2)" ]
      , it "selects on enter"
        [ keyDown 13 "ui-tabs-handle:nth-child(2)" ]
      , it "selects on space"
        [ keyDown 32 "ui-tabs-handle:nth-child(2)" ]
      ]

    , context "Disabled"
      [ it "does not switch tabs"
        [ assert.elementPresent "ui-tabs[disabled] ui-tabs-handle:first-child[selected]"
        , steps.click "ui-tabs[disabled] ui-tabs-handle:nth-child(2)"
        , assert.elementPresent "ui-tabs[disabled] ui-tabs-handle:first-child[selected]"
        ]
      , context "Tabs"
        [ it "does not have tabindex"
          [ assert.not.elementPresent "ui-tabs[disabled] ui-tabs-handle:nth-child(1)[tabindex]"
          , assert.not.elementPresent "ui-tabs[disabled] ui-tabs-handle:nth-child(2)[tabindex]"
          , assert.not.elementPresent "ui-tabs[disabled] ui-tabs-handle:nth-child(3)[tabindex]"
          ]
        ]
      ]

    , context "Readonly"
      [ it "does not switch tabs"
        [ assert.elementPresent "ui-tabs[readonly] ui-tabs-handle:first-child[selected]"
        , steps.click "ui-tabs[readonly] ui-tabs-handle:nth-child(2)"
        , assert.elementPresent "ui-tabs[readonly] ui-tabs-handle:first-child[selected]"
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
