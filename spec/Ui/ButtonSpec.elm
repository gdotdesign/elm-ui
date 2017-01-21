import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Button

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Button
import Ui.Styles

import Steps exposing (keyDown)

type alias Model
  = String

type Msg
  = Set

init : () -> Model
init _ =
  "Initial"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( "Clicked", Cmd.none )

view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Button.style default
      , Ui.Styles.Container.style
      ]
    , Ui.Container.column []
      [ Ui.Container.row []
        [ Ui.Button.primary "Primary" Set
        , Ui.Button.secondary "Secondary" Set
        , Ui.Button.warning "Warning" Set
        , Ui.Button.success "Success" Set
        , Ui.Button.danger "Danger" Set
        ]
      , Ui.Container.row []
        [ Ui.Button.primaryBig "Primary" Set
        , Ui.Button.secondaryBig "Secondary" Set
        , Ui.Button.warningBig "Warning" Set
        , Ui.Button.successBig "Success" Set
        , Ui.Button.dangerBig "Danger" Set
        ]
      , Ui.Container.row []
        [ Ui.Button.primarySmall "Primary" Set
        , Ui.Button.secondarySmall "Secondary" Set
        , Ui.Button.warningSmall "Warning" Set
        , Ui.Button.successSmall "Success" Set
        , Ui.Button.dangerSmall "Danger" Set
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
