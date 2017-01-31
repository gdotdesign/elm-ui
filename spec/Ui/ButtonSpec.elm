import Spec exposing (..)

import Html.Attributes exposing (class)
import Html exposing (div, text)
import Steps exposing (..)
import Ui.Container
import Ui.Button


type alias Model
  = String


type Msg
  = Set


init : () -> String
init _ =
  "Initial"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( "Clicked", Cmd.none )


view : Model -> Html.Html Msg
view model =
  let
    button = Ui.Button.model "" "primary" "medium"
  in
    div
      [ ]
      [ Ui.Container.column []
        [ Ui.Container.row []
          [ Ui.Button.view Set
            { button | text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | text = "Secondary", kind = "secondary" }
          , Ui.Button.view Set
            { button | text = "Warning",   kind = "warning"   }
          , Ui.Button.view Set
            { button | text = "Success",   kind = "success"   }
          , Ui.Button.view Set
            { button | text = "Danger",    kind = "danger"    }
          ]
        , Ui.Container.row []
          [ Ui.Button.view Set
            { button | size = "big", text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | size = "big", text = "Secondary", kind = "secondary" }
          , Ui.Button.view Set
            { button | size = "big", text = "Warning",   kind = "warning"   }
          , Ui.Button.view Set
            { button | size = "big", text = "Success",   kind = "success"   }
          , Ui.Button.view Set
            { button | size = "big", text = "Danger",    kind = "danger"    }
          ]
        , Ui.Container.row []
          [ Ui.Button.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.Button.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          ]
        , Ui.Container.row []
          [ Ui.Button.render
            Set
            { disabled = True
            , readonly = False
            , kind = "primary"
            , size = "medium"
            , text = "Hello"
            }
          , Ui.Button.render
            Set
            { disabled = False
            , readonly = True
            , kind = "primary"
            , size = "medium"
            , text = "Hello"
            }
          ]
        ]
      , div [ class "result" ] [ text model ]
      ]


specs : Node
specs =
  describe "Ui.Button"
    [ it "has tabindex"
      [ assert.elementPresent "ui-button[tabindex]"
      , assert.elementPresent "ui-button[readonly][tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.not.elementPresent "ui-button[disabled][tabindex]"
        ]
      ]
    , context "Actions"
      [ before
        [ assert.containsText { text = "Initial", selector = "div.result" }
        ]
      , after
        [ assert.containsText { text = "Clicked", selector = "div.result" }
        ]
      , it "triggers on click"
        [ steps.click "ui-button"
        ]
      , it "triggers on enter"
        [ keyDown 13 "ui-button"
        ]
      , it "triggers on space"
        [ keyDown 32 "ui-button"
        ]
      ]
    , context "No actions"
      [ before
        [ assert.containsText { text = "Initial", selector = "div.result" }
        ]
      , after
        [ assert.not.containsText { text = "Clicked", selector = "div.result" }
        ]
      , context "Disabled"
        [ it "not triggers on click"
          [ steps.click "ui-button[disabled]"
          ]
        , it "not triggers on enter"
          [ keyDown 13 "ui-button[disabled]"
          ]
        , it "not triggers on space"
          [ keyDown 32 "ui-button[disabled]"
          ]
        ]
      , context "Readonly"
        [ it "should not trigger action on click"
          [ steps.click "ui-button[readonly]"
          ]
        , it "not triggers on enter"
          [ keyDown 13 "ui-button[readonly]"
          ]
        , it "not triggers on space"
          [ keyDown 32 "ui-button[readonly]"
          ]
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
